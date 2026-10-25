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
-- asserts that an input sets the settings of a CV output, which are all in
-- one item, with one of them value
local function assertSetting(input, item, setting, value)
  lu.assertEquals({ input.time_stamp, input.item }, { 0, items[item].index })
  local settings = {}
  settings.pattern, settings.unipolar, settings.bipolar, settings.transition = press.unpackOutputSettings(input.value)
  lu.assertEquals(settings[setting], value)
end

-- asserts that an input sets the switches of a clip, fill-in, landing, intro
-- or outro, which are all in one item, with one of them value, 1 or 0 for
-- present and oneBarPattern
local function assertSwitch(input, item, switch, value)
  lu.assertEquals({ input.time_stamp, input.item }, { 0, items[item].index })
  local switches = {}
  switches.present, switches.colour, switches.oneBarPattern = press.unpackSwitches(input.value)
  local actual = switches[switch]
  if type(actual) == "boolean" then
    actual = actual and 1 or 0
  end
  lu.assertEquals(actual, value)
end

-- the same for the values written to items, by item index
local function assertWrittenSetting(written, item, setting, value)
  assertSetting({ time_stamp = 0, item = items[item].index, value = written[items[item].index] }, item, setting, value)
end

local function assertWrittenSwitch(written, item, switch, value)
  assertSwitch({ time_stamp = 0, item = items[item].index, value = written[items[item].index] }, item, switch, value)
end

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
  lu.assertEquals({ items.setup.min, items.setup.max }, { 0, 395 })
  lu.assertEquals({ items.fillin.min, items.fillin.max }, { 0, 1 })
  lu.assertEquals({ items.fillinlight.min, items.fillinlight.max }, { 0, 42 })
  lu.assertEquals({ items.forwardlight.min, items.forwardlight.max }, { 0, 42 })
  for track = 1, 8 do
    local selection = items["track" .. track .. "selection"]
    lu.assertEquals({ selection.min, selection.max }, { 0, 8 })
    for row = 1, 8 do
      local clip = "track" .. track .. "clip" .. row
      lu.assertEquals({ items[clip .. "light"].min, items[clip .. "light"].max }, { 0, 42 })
      -- whether there is a clip, fill-in, landing, intro or outro, its colour
      -- and one-bar pattern, all in one item
      for _, kind in ipairs({ "", "fillin", "landing", "intro", "outro" }) do
        local item = items[clip .. kind .. "switches"]
        lu.assertEquals({ item.min, item.max }, { 0, 55 })
      end
      for _, letter in ipairs({ "a", "b", "c", "d", "e", "f" }) do
        for _, kind in ipairs({ "", "fillin", "landing", "intro", "outro" }) do
          -- all four settings of an output in one item
          local item = items[clip .. kind .. letter]
          lu.assertEquals({ item.min, item.max }, { 0, 1959 })
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
      local calls = remote.mock "handle_input".calls
      lu.assertEquals(#calls, 2)
      lu.assertEquals(calls[1][1].item, items["track" .. track .. "selection"].index)
      lu.assertEquals(calls[1][1].value, row)
      -- the relaunch press follows the selection, and is let go with the pad
      lu.assertEquals(calls[2][1], { time_stamp = 0, item = items["track" .. track .. "relaunch"].index, value = 1 })
      remote.clearMocks()
      lu.assertTrue(receive(noteOn, pad(track, row), 0))
      lu.assertEquals(handledInput(), { time_stamp = 0, item = items["track" .. track .. "relaunch"].index, value = 0 })
    end
  end
end

function TestProcessLaunchnik:testEmptyPadStopsItsTrack()
  lu.assertTrue(receive(noteOn, pad(3, 5), 127))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(calls[1][1].item, items.track3selection.index)
  lu.assertEquals(calls[1][1].value, 0)
end

function TestProcessLaunchnik:testPadInSetupModeHoldsNoRelaunchPress()
  state.setup = press.setupClipPicking
  lu.assertTrue(receive(noteOn, pad(3, 5), 127))
  lu.assertEquals(handledInput().item, items.setup.index)
  remote.clearMocks()
  lu.assertFalse(receive(noteOn, pad(3, 5), 0))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
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
  assertSwitch(input, "track2clip3switches", "present", 1)
end

function TestProcessLaunchnik:testTogglePadInClipEditingSwitchesThePickedClipOff()
  state.setup = press.setupFirstClipEditing + press.buttonIndex(2, 3)
  state.present[press.buttonIndex(2, 3)] = true
  lu.assertTrue(receive(noteOn, pad(8, 1), 127))
  -- the colour stays
  local input = handledInput()
  assertSwitch(input, "track2clip3switches", "present", 0)
  assertSwitch(input, "track2clip3switches", "colour", 2)
end

function TestProcessLaunchnik:testColourAndCVPadsInClipEditingChangeThePickedClip()
  local picked = press.buttonIndex(2, 3)
  state.setup = press.setupFirstClipEditing + picked
  state.present[picked] = true
  state.cvModes[2][3] = press.cvModeBipolar
  state.transitions[picked][2] = 4

  lu.assertTrue(receive(noteOn, pad(4, 2), 127))
  assertSwitch(handledInput(), "track2clip3switches", "colour", 10)

  -- output A is in pattern mode, B unipolar, C bipolar
  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(6, 3), 127))
  assertSetting(handledInput(), "track2clip3a", "pattern", 5)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(6, 4), 127))
  assertSetting(handledInput(), "track2clip3b", "unipolar", 5)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(2, 5), 127))
  assertSetting(handledInput(), "track2clip3c", "bipolar", 1)

  -- the transition goes round from what the host last reported
  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(8, 4), 127))
  assertSetting(handledInput(), "track2clip3b", "transition", 0)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(8, 5), 127))
  assertSetting(handledInput(), "track2clip3c", "transition", 1)
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
    lu.assertEquals(#calls, 16)
    for track = 1, 8 do
      lu.assertEquals(calls[track][1].item, items["track" .. track .. "selection"].index)
      lu.assertEquals(calls[track][1].value, scene)
      lu.assertEquals(calls[8 + track][1].item, items["track" .. track .. "relaunch"].index)
      lu.assertEquals(calls[8 + track][1].value, 1)
    end
    -- letting go of the scene button lets go of every relaunch press
    remote.clearMocks()
    lu.assertTrue(receive(controlChange, controller, 0))
    calls = remote.mock "handle_input".calls
    lu.assertEquals(#calls, 8)
    for track = 1, 8 do
      lu.assertEquals(calls[track][1], { time_stamp = 0, item = items["track" .. track .. "relaunch"].index, value = 0 })
    end
  end
end

function TestProcessLaunchnik:testSceneButtonStopsTracksWithAnEmptyLaunchButton()
  state.present[press.buttonIndex(2, 8)] = true
  lu.assertTrue(receive(controlChange, 0x13, 127))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 16)
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

-- the button above the second column of pads sends control change 92; it
-- leads from clip editing to fill-in editing and on to landing editing, intro
-- editing and outro editing
function TestProcessLaunchnik:testForwardButtonGoesForwardOneStepWithAClip()
  state.setup = press.setupFirstClipEditing + press.buttonIndex(2, 3)
  state.present[press.buttonIndex(2, 3)] = true
  lu.assertTrue(receive(controlChange, 92, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupFirstFillInEditing + press.buttonIndex(2, 3) })
  remote.clearMocks()
  state.setup = press.setupFirstFillInEditing + press.buttonIndex(2, 3)
  lu.assertTrue(receive(controlChange, 92, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupFirstLandingEditing + press.buttonIndex(2, 3) })
  remote.clearMocks()
  state.setup = press.setupFirstLandingEditing + press.buttonIndex(2, 3)
  lu.assertTrue(receive(controlChange, 92, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupFirstIntroEditing + press.buttonIndex(2, 3) })
  remote.clearMocks()
  state.setup = press.setupFirstIntroEditing + press.buttonIndex(2, 3)
  lu.assertTrue(receive(controlChange, 92, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupFirstOutroEditing + press.buttonIndex(2, 3) })
  remote.clearMocks()
  state.setup = press.setupFirstOutroEditing + press.buttonIndex(2, 3)
  lu.assertTrue(receive(controlChange, 92, 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessLaunchnik:testForwardButtonDoesNothingWithoutAClip()
  state.setup = press.setupFirstClipEditing + press.buttonIndex(2, 3)
  lu.assertTrue(receive(controlChange, 92, 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
  state.setup = press.setupLaunchMode
  lu.assertTrue(receive(controlChange, 92, 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessLaunchnik:testReleasingForwardButtonDoesNothing()
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

function TestProcessLaunchnik:testBackButtonReturnsFromOutroAndIntroEditing()
  state.setup = press.setupFirstOutroEditing + press.buttonIndex(2, 3)
  lu.assertTrue(receive(controlChange, 91, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupFirstIntroEditing + press.buttonIndex(2, 3) })
  remote.clearMocks()
  state.setup = press.setupFirstIntroEditing + press.buttonIndex(2, 3)
  lu.assertTrue(receive(controlChange, 91, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupFirstLandingEditing + press.buttonIndex(2, 3) })
end

-- a new intro or outro is a copy of its clip's values, like a new landing;
-- presses in its editing change it, with its own transitions
function TestProcessLaunchnik:testPadsInIntroAndOutroEditingChangeThem()
  local picked = press.buttonIndex(2, 3)
  state.setup = press.setupFirstIntroEditing + picked
  state.present[picked] = true
  state.patterns[picked][1] = 6
  lu.assertTrue(receive(noteOn, pad(8, 1), 127))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1 + 6)
  assertSwitch(calls[1][1], "track2clip3introswitches", "present", 1)
  assertSetting(calls[2][1], "track2clip3introa", "pattern", 6)
  assertSwitch(calls[1][1], "track2clip3introswitches", "oneBarPattern", 0)

  remote.clearMocks()
  state.setup = press.setupFirstOutroEditing + picked
  state.outroPresent[picked] = true
  state.transitions[picked][2] = 3
  state.outroTransitions[picked][2] = 1
  lu.assertTrue(receive(noteOn, pad(8, 4), 127))
  assertSetting(handledInput(), "track2clip3outrob", "transition", 2)
  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(8, 2), 127))
  assertSwitch(handledInput(), "track2clip3outroswitches", "oneBarPattern", 1)
end

function TestProcessLaunchnik:testBackButtonReturnsFromLandingEditingToFillInEditing()
  state.setup = press.setupFirstLandingEditing + press.buttonIndex(2, 3)
  lu.assertTrue(receive(controlChange, 91, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupFirstFillInEditing + press.buttonIndex(2, 3) })
end

-- a new landing is a copy of its clip's values, with every transition off,
-- in white, like a new fill-in
function TestProcessLaunchnik:testTogglePadInLandingEditingSetsUpANewLanding()
  local picked = press.buttonIndex(2, 3)
  state.setup = press.setupFirstLandingEditing + picked
  state.present[picked] = true
  -- a fill-in makes no difference
  state.fillInPresent[picked] = true
  state.patterns[picked][1] = 6
  state.unipolar[picked][2] = 4
  state.bipolar[picked][6] = 1
  lu.assertTrue(receive(noteOn, pad(8, 1), 127))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1 + 6)
  assertSwitch(calls[1][1], "track2clip3landingswitches", "oneBarPattern", 0)
  assertSwitch(calls[1][1], "track2clip3landingswitches", "present", 1)
  assertSwitch(calls[1][1], "track2clip3landingswitches", "colour", 0)
  assertSetting(calls[2][1], "track2clip3landinga", "pattern", 6)
  assertSetting(calls[3][1], "track2clip3landingb", "unipolar", 4)
  assertSetting(calls[7][1], "track2clip3landingf", "bipolar", 1)
  assertSetting(calls[7][1], "track2clip3landingf", "transition", 0)
end

function TestProcessLaunchnik:testColourAndCVPadsInLandingEditingChangeTheLanding()
  local picked = press.buttonIndex(2, 3)
  state.setup = press.setupFirstLandingEditing + picked
  state.present[picked] = true
  state.landingPresent[picked] = true
  -- the landing's transition counts, not the clip's or the fill-in's
  state.transitions[picked][2] = 3
  state.fillInTransitions[picked][2] = 0
  state.landingTransitions[picked][2] = 4

  lu.assertTrue(receive(noteOn, pad(8, 1), 127))
  assertSwitch(handledInput(), "track2clip3landingswitches", "present", 0)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(4, 2), 127))
  assertSwitch(handledInput(), "track2clip3landingswitches", "colour", 10)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(6, 3), 127))
  assertSetting(handledInput(), "track2clip3landinga", "pattern", 5)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(3, 4), 127))
  assertSetting(handledInput(), "track2clip3landingb", "unipolar", 2)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(8, 4), 127))
  assertSetting(handledInput(), "track2clip3landingb", "transition", 0)

  -- the one-bar pattern switch goes on, and off again
  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(8, 2), 127))
  assertSwitch(handledInput(), "track2clip3landingswitches", "oneBarPattern", 1)
  remote.clearMocks()
  state.landingOneBarPattern[picked] = true
  lu.assertTrue(receive(noteOn, pad(8, 2), 127))
  assertSwitch(handledInput(), "track2clip3landingswitches", "oneBarPattern", 0)
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
  lu.assertEquals(#calls, 1 + 6)
  assertSwitch(calls[1][1], "track2clip3fillinswitches", "oneBarPattern", 0)
  assertSwitch(calls[1][1], "track2clip3fillinswitches", "present", 1)
  assertSwitch(calls[1][1], "track2clip3fillinswitches", "colour", 0)
  assertSetting(calls[2][1], "track2clip3fillina", "pattern", 6)
  assertSetting(calls[3][1], "track2clip3fillinb", "unipolar", 4)
  assertSetting(calls[7][1], "track2clip3fillinf", "bipolar", 1)
  assertSetting(calls[7][1], "track2clip3fillinf", "transition", 0)
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
  assertSwitch(handledInput(), "track2clip3fillinswitches", "present", 0)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(4, 2), 127))
  assertSwitch(handledInput(), "track2clip3fillinswitches", "colour", 10)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(6, 3), 127))
  assertSetting(handledInput(), "track2clip3fillina", "pattern", 5)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(3, 4), 127))
  assertSetting(handledInput(), "track2clip3fillinb", "unipolar", 2)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(8, 4), 127))
  assertSetting(handledInput(), "track2clip3fillinb", "transition", 2)

  -- the pad in the last track of the second colour row switches one-bar
  -- pattern
  remote.clearMocks()
  state.fillInOneBarPattern[picked] = true
  lu.assertTrue(receive(noteOn, pad(8, 2), 127))
  assertSwitch(handledInput(), "track2clip3fillinswitches", "oneBarPattern", 0)
end

-- the button to the left of the third row of pads from the top sends control
-- change 60; it switches between launch mode and clear mode, and does
-- nothing in setup mode
function TestProcessLaunchnik:testClearButtonSwitchesBetweenLaunchModeAndClearMode()
  lu.assertTrue(receive(controlChange, 60, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupClearMode })

  remote.clearMocks()
  state.setup = press.setupClearMode
  lu.assertTrue(receive(controlChange, 60, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupLaunchMode })
end

function TestProcessLaunchnik:testClearButtonDoesNothingInSetupMode()
  state.setup = press.setupClipPicking
  lu.assertTrue(receive(controlChange, 60, 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessLaunchnik:testReleasingClearButtonDoesNothing()
  lu.assertFalse(receive(controlChange, 60, 0))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessLaunchnik:testBackButtonLeavesClearMode()
  state.setup = press.setupClearMode
  lu.assertTrue(receive(controlChange, 91, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupLaunchMode })
end

-- a pad in clear mode empties its launch button and returns to launch mode,
-- holding no relaunch press
function TestProcessLaunchnik:testPadInClearModeClearsItsLaunchButton()
  state.setup = press.setupClearMode
  state.present[press.buttonIndex(3, 2)] = true
  lu.assertTrue(receive(noteOn, pad(3, 2), 127))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 2)
  assertSwitch(calls[1][1], "track3clip2switches", "present", 0)
  lu.assertEquals(calls[2][1], { time_stamp = 0, item = items.setup.index, value = press.setupLaunchMode })
  lu.assertNil(state.heldRelaunches[3])
end

function TestProcessLaunchnik:testEmptyPadInClearModeOnlyReturnsToLaunchMode()
  state.setup = press.setupClearMode
  lu.assertTrue(receive(noteOn, pad(3, 2), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupLaunchMode })
end

-- a scene button in clear mode empties every launch button of its scene that
-- holds a clip and returns to launch mode; the top one sends 89
function TestProcessLaunchnik:testSceneButtonInClearModeClearsItsScene()
  state.setup = press.setupClearMode
  state.present[press.buttonIndex(2, 1)] = true
  state.present[press.buttonIndex(7, 1)] = true
  lu.assertTrue(receive(controlChange, 89, 127))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 3)
  assertSwitch(calls[1][1], "track2clip1switches", "present", 0)
  assertSwitch(calls[2][1], "track7clip1switches", "present", 0)
  lu.assertEquals(calls[3][1], { time_stamp = 0, item = items.setup.index, value = press.setupLaunchMode })
  lu.assertEquals(state.heldRelaunches, {})
end

-- the button to the left of the fourth row of pads sends control change 50
function TestProcessLaunchnik:testDuplicateButtonSwitchesBetweenLaunchModeAndDuplicateMode()
  lu.assertTrue(receive(controlChange, 50, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupSourcePicking })

  remote.clearMocks()
  state.setup = press.setupFirstClipDestinationPicking + press.buttonIndex(3, 2)
  lu.assertTrue(receive(controlChange, 50, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupLaunchMode })
end

function TestProcessLaunchnik:testDuplicateButtonDoesNothingInSetupModeAndClearMode()
  for _, step in ipairs({ press.setupClipPicking, press.setupClearMode }) do
    remote.clearMocks()
    state.setup = step
    lu.assertTrue(receive(controlChange, 50, 127))
    lu.assertEquals(#remote.mock "handle_input".calls, 0)
  end
end

function TestProcessLaunchnik:testReleasingDuplicateButtonDoesNothing()
  lu.assertFalse(receive(controlChange, 50, 0))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessLaunchnik:testBackButtonLeavesDuplicateMode()
  state.setup = press.setupSourcePicking
  lu.assertTrue(receive(controlChange, 91, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupLaunchMode })
end

-- in source picking a pad with a clip picks its launch button, holding no
-- relaunch press; an empty one does nothing
function TestProcessLaunchnik:testPadInSourcePickingPicksTheSource()
  state.setup = press.setupSourcePicking
  state.present[press.buttonIndex(3, 2)] = true
  lu.assertTrue(receive(noteOn, pad(3, 2), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupFirstClipDestinationPicking + press.buttonIndex(3, 2) })
  lu.assertNil(state.heldRelaunches[3])

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(4, 2), 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

-- the values the host reports about every setting of track 3, row 2
local function reportSource()
  local source = press.buttonIndex(3, 2)
  state.present[source] = true
  state.colours[source] = 9
  state.fillInPresent[source] = true
  state.fillInColours[source] = 4
  state.fillInOneBarPattern[source] = true
  state.landingColours[source] = 11
  for output = 1, 6 do
    state.patterns[source][output] = output
    state.unipolar[source][output] = 6 - output
    state.fillInBipolar[source][output] = output
    state.landingTransitions[source][output] = output % 5
  end
end

-- in destination picking a pad writes every setting of the source to its
-- launch button through the items of that launch button, then returns to
-- launch mode
function TestProcessLaunchnik:testPadInDestinationPickingCopiesTheSource()
  reportSource()
  state.setup = press.setupFirstClipDestinationPicking + press.buttonIndex(3, 2)
  lu.assertTrue(receive(noteOn, pad(5, 7), 127))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 36)
  local written = {}
  for _, call in ipairs(calls) do
    written[call[1].item] = call[1].value
  end
  assertWrittenSwitch(written, "track5clip7switches", "present", 1)
  assertWrittenSwitch(written, "track5clip7switches", "colour", 9)
  assertWrittenSwitch(written, "track5clip7fillinswitches", "present", 1)
  assertWrittenSwitch(written, "track5clip7fillinswitches", "colour", 4)
  assertWrittenSwitch(written, "track5clip7fillinswitches", "oneBarPattern", 1)
  assertWrittenSwitch(written, "track5clip7landingswitches", "present", 0)
  assertWrittenSwitch(written, "track5clip7landingswitches", "colour", 11)
  assertWrittenSetting(written, "track5clip7c", "pattern", 3)
  assertWrittenSetting(written, "track5clip7b", "unipolar", 4)
  assertWrittenSetting(written, "track5clip7fillinf", "bipolar", 6)
  assertWrittenSetting(written, "track5clip7landingd", "transition", 4)
  lu.assertEquals(calls[36][1], { time_stamp = 0, item = items.setup.index, value = press.setupLaunchMode })
end

function TestProcessLaunchnik:testSourcePadInDestinationPickingDoesNothing()
  reportSource()
  state.setup = press.setupFirstClipDestinationPicking + press.buttonIndex(3, 2)
  lu.assertTrue(receive(noteOn, pad(3, 2), 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

-- in source picking a scene button with a clip in its scene picks the scene;
-- in destination picking another scene button copies the whole scene there,
-- empty launch buttons included, and returns to launch mode
function TestProcessLaunchnik:testSceneButtonsDuplicateAScene()
  reportSource()
  state.setup = press.setupSourcePicking
  lu.assertTrue(receive(controlChange, 79, 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.setup.index, value = press.setupFirstSceneDestinationPicking + 1 })

  remote.clearMocks()
  state.setup = press.setupFirstSceneDestinationPicking + 1
  state.present[press.buttonIndex(6, 8)] = true
  lu.assertTrue(receive(controlChange, 19, 127))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 8 * 35 + 1)
  local written = {}
  for _, call in ipairs(calls) do
    written[call[1].item] = call[1].value
  end
  assertWrittenSwitch(written, "track3clip8switches", "present", 1)
  assertWrittenSwitch(written, "track3clip8switches", "colour", 9)
  assertWrittenSwitch(written, "track6clip8switches", "present", 0)
  lu.assertEquals(calls[#calls][1], { time_stamp = 0, item = items.setup.index, value = press.setupLaunchMode })
  lu.assertEquals(state.heldRelaunches, {})
end
