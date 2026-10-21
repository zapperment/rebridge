local test = require "test.lib._"
local lu = test.luaUnit
local items = require "src.lppmk3.config.items"
local launchnik = require "src.lppmk3.lib.launchnik._"
local processLaunchnik = require "src.lppmk3.remote.processMidi.launchnik"
local defineItemIndices = require "test.lppmk3.defineItemIndices"

TestProcessLaunchnik = {}

local noteOn = 144
local controlChange = 176
local state = launchnik.state
local press = launchnik.press

-- simulates the remote surface sending the given MIDI message
local function receive(status, data1, data2)
  remote.mock "match_midi":impl(function()
    return { x = status, y = data1, z = data2 }
  end)
  return processLaunchnik.processPadsAndTrackButtons({ time_stamp = 0 })
end

-- the pad in the given place sends this note; row 1 is the top row
local function pad(track, row)
  return (9 - row) * 10 + track
end

-- the input passed to the only call of remote.handle_input
local function handledInput()
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1)
  return calls[1][1]
end

function TestProcessLaunchnik:setUp()
  remote.clearMocks()
  defineItemIndices()
  state.reset()
end

function TestProcessLaunchnik:tearDown()
  state.reset()
end

-- the host scales an item's range onto the remotable's, so the ranges have to
-- be those of Launchnik's Remote items for the values to arrive unchanged
function TestProcessLaunchnik:testItemRangesAreThoseOfLaunchniksRemoteItems()
  lu.assertEquals({ items.setup.min, items.setup.max }, { 0, 129 })
  lu.assertEquals({ items.fillin.min, items.fillin.max }, { 0, 1 })
  lu.assertEquals({ items.fillinlight.min, items.fillinlight.max }, { 0, 42 })
  lu.assertEquals({ items.setfillinlight.min, items.setfillinlight.max }, { 0, 42 })
  for track = 1, 8 do
    local selection = items["track" .. track .. "selection"]
    lu.assertEquals({ selection.min, selection.max }, { 0, 8 })
    for row = 1, 8 do
      local clip = "track" .. track .. "clip" .. row
      lu.assertEquals({ items[clip .. "light"].min, items[clip .. "light"].max }, { 0, 42 })
      lu.assertEquals({ items[clip .. "present"].min, items[clip .. "present"].max }, { 0, 1 })
      lu.assertEquals({ items[clip .. "colour"].min, items[clip .. "colour"].max }, { 0, 13 })
      lu.assertEquals({ items[clip .. "fillinpresent"].min, items[clip .. "fillinpresent"].max }, { 0, 1 })
      lu.assertEquals({ items[clip .. "fillincolour"].min, items[clip .. "fillincolour"].max }, { 0, 13 })
      for _, letter in ipairs({ "a", "b", "c", "d", "e", "f" }) do
        for _, kind in ipairs({ "", "fillin" }) do
          local prefix = clip .. kind .. letter
          lu.assertEquals({ items[prefix .. "pattern"].min, items[prefix .. "pattern"].max }, { 0, 7 })
          lu.assertEquals({ items[prefix .. "unipolar"].min, items[prefix .. "unipolar"].max }, { 0, 6 })
          lu.assertEquals({ items[prefix .. "bipolar"].min, items[prefix .. "bipolar"].max }, { 0, 6 })
          lu.assertEquals({ items[prefix .. "transition"].min, items[prefix .. "transition"].max }, { 0, 4 })
        end
      end
    end
    for _, letter in ipairs({ "a", "b", "c", "d", "e", "f" }) do
      local cvMode = items["track" .. track .. "cvmode" .. letter]
      lu.assertEquals({ cvMode.min, cvMode.max }, { 0, 2 })
    end
  end
end

function TestProcessLaunchnik:testEveryPadWithAClipSelectsItsRowOfItsTrack()
  for index = 0, 63 do
    state.present[index] = true
  end
  for row = 1, 8 do
    for track = 1, 8 do
      remote.clearMocks()
      lu.assertTrue(receive(noteOn, pad(track, row), 127))
      local input = handledInput()
      lu.assertEquals(input.item, items["track" .. track .. "selection"].index)
      lu.assertEquals(input.value, row)
    end
  end
end

function TestProcessLaunchnik:testEmptyPadStopsItsTrack()
  lu.assertTrue(receive(noteOn, pad(3, 5), 127))
  local input = handledInput()
  lu.assertEquals(input.item, items.track3selection.index)
  lu.assertEquals(input.value, 0)
end

-- the function buttons are control changes 101 to 108
function TestProcessLaunchnik:testFunctionButtonStopsItsTrackInEveryMode()
  state.present[press.buttonIndex(3, 1)] = true
  for _, setup in ipairs { press.setupLaunchMode, press.setupClipPicking, press.setupFirstClipEditing } do
    remote.clearMocks()
    state.setup = setup
    lu.assertTrue(receive(controlChange, 103, 127))
    local input = handledInput()
    lu.assertEquals(input.item, items.track3selection.index)
    lu.assertEquals(input.value, 0)
    remote.clearMocks()
    lu.assertTrue(receive(controlChange, 103, 0))
    lu.assertEquals(#remote.mock "handle_input".calls, 0)
  end
end

function TestProcessLaunchnik:testFunctionButtonOfATrackWithoutClipsDoesNothing()
  for func = 0, 2 do
    remote.clearMocks()
    state["function"] = func
    lu.assertTrue(receive(controlChange, 103, 127))
    lu.assertTrue(receive(controlChange, 103, 0))
    lu.assertEquals(#remote.mock "handle_input".calls, 0)
  end
end

-- in mute and solo function a function button is held down for as long as the
-- button on the surface is
function TestProcessLaunchnik:testFunctionButtonIsHeldAsMuteOrSoloButton()
  state.present[press.buttonIndex(5, 2)] = true
  for func, name in pairs { [press.functionMute] = "mute", [press.functionSolo] = "solo" } do
    state["function"] = func
    remote.clearMocks()
    lu.assertTrue(receive(controlChange, 105, 127))
    local input = handledInput()
    lu.assertEquals(input.item, items["track5" .. name].index)
    lu.assertEquals(input.value, 1)
    remote.clearMocks()
    lu.assertTrue(receive(controlChange, 105, 0))
    input = handledInput()
    lu.assertEquals(input.item, items["track5" .. name].index)
    lu.assertEquals(input.value, 0)
  end
end

-- letting go lets go of the button that was pressed, even if the function has
-- changed meanwhile
function TestProcessLaunchnik:testLettingGoOfAFunctionButtonLetsGoOfWhatWasPressed()
  state.present[press.buttonIndex(5, 2)] = true
  state["function"] = press.functionMute
  receive(controlChange, 105, 127)
  state["function"] = press.functionStop
  remote.clearMocks()
  lu.assertTrue(receive(controlChange, 105, 0))
  local input = handledInput()
  lu.assertEquals(input.item, items.track5mute.index)
  lu.assertEquals(input.value, 0)
end

-- the function select buttons are control changes 2 (mute), 3 (solo) and 8
-- (stop) in the row below the function buttons
function TestProcessLaunchnik:testFunctionSelectButtonsChooseTheFunction()
  for control, func in pairs { [2] = 1, [3] = 2, [8] = 0 } do
    remote.clearMocks()
    lu.assertTrue(receive(controlChange, control, 127))
    local input = handledInput()
    lu.assertEquals(input.item, items["function"].index)
    lu.assertEquals(input.value, func)
  end
  -- the other buttons of the row do nothing
  for _, control in ipairs { 1, 4, 5, 6, 7 } do
    remote.clearMocks()
    receive(controlChange, control, 127)
    lu.assertEquals(#remote.mock "handle_input".calls, 0)
  end
end

function TestProcessLaunchnik:testPadInClipPickingOpensItsLaunchButton()
  state.setup = press.setupClipPicking
  lu.assertTrue(receive(noteOn, pad(2, 3), 127))
  local input = handledInput()
  lu.assertEquals(input.item, items.setup.index)
  lu.assertEquals(input.value, 2 + 8 + 2)
end

function TestProcessLaunchnik:testTogglePadInClipEditingSwitchesThePickedClipOn()
  state.setup = press.setupFirstClipEditing + press.buttonIndex(2, 3)
  lu.assertTrue(receive(noteOn, pad(8, 1), 127))
  local input = handledInput()
  lu.assertEquals(input.item, items.track2clip3present.index)
  lu.assertEquals(input.value, 1)
end

function TestProcessLaunchnik:testTogglePadInClipEditingSwitchesThePickedClipOff()
  state.setup = press.setupFirstClipEditing + press.buttonIndex(2, 3)
  state.present[press.buttonIndex(2, 3)] = true
  lu.assertTrue(receive(noteOn, pad(8, 1), 127))
  lu.assertEquals(handledInput().value, 0)
end

function TestProcessLaunchnik:testColourAndCVPadsInClipEditingChangeThePickedClip()
  local picked = press.buttonIndex(2, 3)
  state.setup = press.setupFirstClipEditing + picked
  state.present[picked] = true
  state.cvModes[2][3] = press.cvModeBipolar
  state.transitions[picked][2] = 4

  lu.assertTrue(receive(noteOn, pad(4, 2), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3colour.index, value = 10 })

  -- output A is in pattern mode, B unipolar, C bipolar
  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(6, 3), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3apattern.index, value = 5 })

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(6, 4), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3bunipolar.index, value = 5 })

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(2, 5), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3cbipolar.index, value = 1 })

  -- the transition goes round from what the host last reported
  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(8, 4), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3btransition.index, value = 0 })

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(8, 5), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3ctransition.index, value = 1 })
end

function TestProcessLaunchnik:testPadWithoutMeaningIsSwallowed()
  state.setup = press.setupFirstClipEditing
  lu.assertTrue(receive(noteOn, pad(1, 7), 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessLaunchnik:testReleasingPadDoesNothing()
  lu.assertFalse(receive(noteOn, 81, 0))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessLaunchnik:testIgnoresOtherControlChanges()
  lu.assertFalse(receive(controlChange, 90, 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

-- the scene buttons send these control changes, from the bottom to the top
local sceneButtons = { 0x13, 0x1d, 0x27, 0x31, 0x3b, 0x45, 0x4f, 0x59 }

function TestProcessLaunchnik:testEverySceneButtonSelectsItsRowOnEveryTrack()
  for index = 0, 63 do
    state.present[index] = true
  end
  for fromBottom, controller in ipairs(sceneButtons) do
    remote.clearMocks()
    local scene = 9 - fromBottom
    lu.assertTrue(receive(controlChange, controller, 127))
    local calls = remote.mock "handle_input".calls
    lu.assertEquals(#calls, 8)
    for track = 1, 8 do
      lu.assertEquals(calls[track][1].item, items["track" .. track .. "selection"].index)
      lu.assertEquals(calls[track][1].value, scene)
    end
  end
end

function TestProcessLaunchnik:testSceneButtonStopsTracksWithAnEmptyLaunchButton()
  state.present[press.buttonIndex(2, 8)] = true
  lu.assertTrue(receive(controlChange, 0x13, 127))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 8)
  for track = 1, 8 do
    lu.assertEquals(calls[track][1].item, items["track" .. track .. "selection"].index)
    lu.assertEquals(calls[track][1].value, track == 2 and 8 or 0)
  end
end

function TestProcessLaunchnik:testSceneButtonIsSwallowedInClipEditing()
  state.setup = press.setupFirstClipEditing
  lu.assertTrue(receive(controlChange, 0x59, 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

-- from the bottom: immediate, one beat, half a bar, 1, 2, 4, 8 and 16 bars
function TestProcessLaunchnik:testSceneButtonInClipPickingChoosesItsLengthAndLeavesSetupMode()
  for fromBottom, controller in ipairs(sceneButtons) do
    remote.clearMocks()
    state.setup = press.setupClipPicking
    lu.assertTrue(receive(controlChange, controller, 127))
    local calls = remote.mock "handle_input".calls
    lu.assertEquals(#calls, 2)
    lu.assertEquals(calls[1][1].item, items.switchinterval.index)
    lu.assertEquals(calls[1][1].value, fromBottom - 1)
    lu.assertEquals(calls[2][1].item, items.setup.index)
    lu.assertEquals(calls[2][1].value, press.setupLaunchMode)
  end
end

function TestProcessLaunchnik:testSwitchIntervalItemHasTheRangeOfTheLengths()
  lu.assertEquals({ items.switchinterval.min, items.switchinterval.max }, { 0, 7 })
end

function TestProcessLaunchnik:testReleasingSceneButtonDoesNothing()
  lu.assertFalse(receive(controlChange, 0x59, 0))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessLaunchnik:testSceneLightItemsHaveTheRangeOfALight()
  for scene = 1, 8 do
    local light = items["scene" .. scene .. "light"]
    lu.assertEquals({ light.min, light.max }, { 0, 42 })
  end
end

-- the button with the arrow pointing left sends control change 91
function TestProcessLaunchnik:testBackButtonGoesBackOneStep()
  state.setup = press.setupFirstClipEditing + 12
  lu.assertTrue(receive(controlChange, 91, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupClipPicking })

  remote.clearMocks()
  state.setup = press.setupClipPicking
  lu.assertTrue(receive(controlChange, 91, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupLaunchMode })
end

function TestProcessLaunchnik:testBackButtonDoesNothingInLaunchMode()
  lu.assertTrue(receive(controlChange, 91, 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessLaunchnik:testReleasingBackButtonDoesNothing()
  state.setup = press.setupClipPicking
  lu.assertFalse(receive(controlChange, 91, 0))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

-- the button to the left of the sixth row of pads sends control change 30; it
-- holds Launchnik's fill-in button down for as long as it is held, in every
-- mode
function TestProcessLaunchnik:testFillInButtonIsHeldWhileItsButtonIs()
  for _, setup in ipairs({ press.setupLaunchMode, press.setupClipPicking, press.setupFirstFillInEditing }) do
    remote.clearMocks()
    state.setup = setup
    lu.assertTrue(receive(controlChange, 30, 127))
    lu.assertEquals(handledInput(), { time_stamp = 0, item = items.fillin.index, value = 1 })
    remote.clearMocks()
    lu.assertTrue(receive(controlChange, 30, 0))
    lu.assertEquals(handledInput(), { time_stamp = 0, item = items.fillin.index, value = 0 })
  end
end

-- the button above the second column of pads sends control change 92
function TestProcessLaunchnik:testSetFillInButtonGoesOnFromClipEditingOfAClip()
  state.setup = press.setupFirstClipEditing + press.buttonIndex(2, 3)
  state.present[press.buttonIndex(2, 3)] = true
  lu.assertTrue(receive(controlChange, 92, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupFirstFillInEditing + press.buttonIndex(2, 3) })
end

function TestProcessLaunchnik:testSetFillInButtonDoesNothingWithoutAClip()
  state.setup = press.setupFirstClipEditing + press.buttonIndex(2, 3)
  lu.assertTrue(receive(controlChange, 92, 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
  state.setup = press.setupLaunchMode
  lu.assertTrue(receive(controlChange, 92, 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessLaunchnik:testReleasingSetFillInButtonDoesNothing()
  state.setup = press.setupFirstClipEditing + press.buttonIndex(2, 3)
  state.present[press.buttonIndex(2, 3)] = true
  lu.assertFalse(receive(controlChange, 92, 0))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessLaunchnik:testBackButtonReturnsFromFillInEditingToClipEditing()
  state.setup = press.setupFirstFillInEditing + press.buttonIndex(2, 3)
  lu.assertTrue(receive(controlChange, 91, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupFirstClipEditing + press.buttonIndex(2, 3) })
end

-- a new fill-in is a copy of its clip's values, with every transition off,
-- in white
function TestProcessLaunchnik:testTogglePadInFillInEditingSetsUpANewFillIn()
  local picked = press.buttonIndex(2, 3)
  state.setup = press.setupFirstFillInEditing + picked
  state.present[picked] = true
  state.patterns[picked][1] = 6
  state.unipolar[picked][2] = 4
  state.bipolar[picked][6] = 1
  lu.assertTrue(receive(noteOn, pad(8, 1), 127))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 2 + 4 * 6)
  lu.assertEquals(calls[1][1], { time_stamp = 0, item = items.track2clip3fillinpresent.index, value = 1 })
  lu.assertEquals(calls[2][1], { time_stamp = 0, item = items.track2clip3fillincolour.index, value = 0 })
  lu.assertEquals(calls[3][1], { time_stamp = 0, item = items.track2clip3fillinapattern.index, value = 6 })
  lu.assertEquals(calls[8][1], { time_stamp = 0, item = items.track2clip3fillinbunipolar.index, value = 4 })
  lu.assertEquals(calls[25][1], { time_stamp = 0, item = items.track2clip3fillinfbipolar.index, value = 1 })
  lu.assertEquals(calls[26][1], { time_stamp = 0, item = items.track2clip3fillinftransition.index, value = 0 })
end

function TestProcessLaunchnik:testColourAndCVPadsInFillInEditingChangeTheFillIn()
  local picked = press.buttonIndex(2, 3)
  state.setup = press.setupFirstFillInEditing + picked
  state.present[picked] = true
  state.fillInPresent[picked] = true
  -- the fill-in's transition counts, not the clip's
  state.transitions[picked][2] = 3
  state.fillInTransitions[picked][2] = 1

  lu.assertTrue(receive(noteOn, pad(8, 1), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3fillinpresent.index, value = 0 })

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(4, 2), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3fillincolour.index, value = 10 })

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(6, 3), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3fillinapattern.index, value = 5 })

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(3, 4), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3fillinbunipolar.index, value = 2 })

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(8, 4), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3fillinbtransition.index, value = 2 })

  -- the pad in the last track of the second colour row is swallowed
  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(8, 2), 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end
