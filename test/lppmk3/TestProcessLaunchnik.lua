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
      lu.assertEquals({ items[clip .. "pattern"].min, items[clip .. "pattern"].max }, { 0, 7 })
      lu.assertEquals({ items[clip .. "colour"].min, items[clip .. "colour"].max }, { 0, 13 })
      lu.assertEquals({ items[clip .. "fillinpresent"].min, items[clip .. "fillinpresent"].max }, { 0, 1 })
      lu.assertEquals({ items[clip .. "fillinpattern"].min, items[clip .. "fillinpattern"].max }, { 0, 7 })
      lu.assertEquals({ items[clip .. "fillincolour"].min, items[clip .. "fillincolour"].max }, { 0, 13 })
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

function TestProcessLaunchnik:testTrackButtonStopsItsTrackInEveryMode()
  for _, setup in ipairs { press.setupLaunchMode, press.setupClipPicking, press.setupFirstClipEditing } do
    remote.clearMocks()
    state.setup = setup
    lu.assertTrue(receive(controlChange, 103, 127))
    local input = handledInput()
    lu.assertEquals(input.item, items.track3selection.index)
    lu.assertEquals(input.value, 0)
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

function TestProcessLaunchnik:testColourAndPatternPadsInClipEditingChangeThePickedClip()
  state.setup = press.setupFirstClipEditing + press.buttonIndex(2, 3)
  state.present[press.buttonIndex(2, 3)] = true

  lu.assertTrue(receive(noteOn, pad(4, 3), 127))
  local input = handledInput()
  lu.assertEquals(input.item, items.track2clip3colour.index)
  lu.assertEquals(input.value, 10)

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(6, 5), 127))
  input = handledInput()
  lu.assertEquals(input.item, items.track2clip3pattern.index)
  lu.assertEquals(input.value, 5)
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

-- a new fill-in has the pattern of its clip, in white
function TestProcessLaunchnik:testTogglePadInFillInEditingSetsUpANewFillIn()
  state.setup = press.setupFirstFillInEditing + press.buttonIndex(2, 3)
  state.present[press.buttonIndex(2, 3)] = true
  state.patterns[press.buttonIndex(2, 3)] = 6
  lu.assertTrue(receive(noteOn, pad(8, 1), 127))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 3)
  lu.assertEquals(calls[1][1], { time_stamp = 0, item = items.track2clip3fillinpresent.index, value = 1 })
  lu.assertEquals(calls[2][1], { time_stamp = 0, item = items.track2clip3fillinpattern.index, value = 6 })
  lu.assertEquals(calls[3][1], { time_stamp = 0, item = items.track2clip3fillincolour.index, value = 0 })
end

function TestProcessLaunchnik:testColourAndPatternPadsInFillInEditingChangeTheFillIn()
  state.setup = press.setupFirstFillInEditing + press.buttonIndex(2, 3)
  state.present[press.buttonIndex(2, 3)] = true
  state.fillInPresent[press.buttonIndex(2, 3)] = true

  lu.assertTrue(receive(noteOn, pad(8, 1), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3fillinpresent.index, value = 0 })

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(4, 3), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3fillincolour.index, value = 10 })

  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(6, 5), 127))
  lu.assertEquals(handledInput(), { time_stamp = 0, item = items.track2clip3fillinpattern.index, value = 5 })

  -- other pads are swallowed
  remote.clearMocks()
  lu.assertTrue(receive(noteOn, pad(1, 1), 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end
