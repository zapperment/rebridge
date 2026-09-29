local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lppmk3.lib.state._"
local ctrl = require "src.lppmk3.config.controls"
local const = require "src.lppmk3.config.constants"
local colours = require "src.lppmk3.lib.colour.config"
local processPads = require "src.lppmk3.remote.processMidi.pads"

TestProcessPads = {}

-- simulates pressing the pad with the given note number
local function pressPad(note)
  remote.mock "match_midi":impl(function(midi)
    if midi == "90 xx yy" then
      return { x = note, y = 127 }
    end
    return nil
  end)
  return processPads({ time_stamp = 0 })
end

function TestProcessPads:setUp()
  remote.clearMocks()
  state.setShifted(false)
  for _, device in ipairs(ctrl.devices) do
    state.set(device .. ".hostValue", 0)
    state.update(device .. ".hostValue")
    state.set(device .. ".playingValue", 0)
    state.update(device .. ".playingValue")
    for value = 1, const.counts.patternValues do
      state.set(device .. ".colour" .. value, colours.white.dim)
      state.update(device .. ".colour" .. value)
    end
  end
end

function TestProcessPads:testPatternValuesStartWhite()
  local StateManager = require "src.lppmk3.lib.state.StateManager"
  local stateManager = StateManager:new()
  for value = 1, const.counts.patternValues do
    lu.assertEquals(stateManager:get("device1.colour" .. value), colours.white.dim)
  end
end

-- sets the pattern of a device with no switch pending
local function setValue(device, value)
  state.set(device .. ".hostValue", value)
  state.set(device .. ".playingValue", value)
end

-- the value sent to the host by the only call of remote.handle_input
local function sentValue()
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1)
  return calls[1][1].value
end

function TestProcessPads:testSelectsPatternWithoutShift()
  lu.assertTrue(pressPad(83))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1)
  lu.assertEquals(calls[1][1].value, 3)
  lu.assertEquals(state.get "device1.colour3", colours.white.dim)
end

function TestProcessPads:testCyclesColourOfLitPadWithShift()
  setValue("device3", 3)
  state.shift()
  lu.assertTrue(pressPad(63))
  lu.assertEquals(state.get "device3.colour3", colours.red.vibrant)
  pressPad(63)
  lu.assertEquals(state.get "device3.colour3", colours.orange.vibrant)
end

function TestProcessPads:testCyclesOnlyColourOfTappedValue()
  setValue("device3", 3)
  state.shift()
  pressPad(63)
  for value = 1, const.counts.patternValues do
    if value ~= 3 then
      lu.assertEquals(state.get("device3.colour" .. value), colours.white.dim)
    end
  end
  lu.assertEquals(state.get "device1.colour3", colours.white.dim)
end

function TestProcessPads:testDoesNothingWithShiftOnUnlitPad()
  setValue("device3", 3)
  state.shift()
  lu.assertTrue(pressPad(68))
  lu.assertEquals(state.get "device3.colour8", colours.white.dim)
  lu.assertEquals(state.get "device3.colour3", colours.white.dim)
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessPads:testDoesNothingWithShiftWhenNoPadIsLit()
  state.shift()
  pressPad(63)
  lu.assertEquals(state.get "device3.colour3", colours.white.dim)
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessPads:testDoesNotSelectPatternWithShift()
  state.set("device1.hostValue", 3)
  state.shift()
  pressPad(83)
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessPads:testStopsPlayingPatternWhenNothingIsPending()
  setValue("device1", 3)
  pressPad(83)
  lu.assertEquals(sentValue(), 0)
end

function TestProcessPads:testSelectsOtherPatternWhenNothingIsPending()
  setValue("device1", 3)
  pressPad(85)
  lu.assertEquals(sentValue(), 5)
end

function TestProcessPads:testDoesNothingOnPendingPad()
  setValue("device1", 3)
  state.set("device1.hostValue", 5)
  lu.assertTrue(pressPad(85))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessPads:testCancelsPendingPatternOnPlayingPad()
  setValue("device1", 3)
  state.set("device1.hostValue", 5)
  pressPad(83)
  lu.assertEquals(sentValue(), 3)
end

function TestProcessPads:testCancelsPendingStopOnPlayingPad()
  setValue("device1", 3)
  state.set("device1.hostValue", 0)
  pressPad(83)
  lu.assertEquals(sentValue(), 3)
end

function TestProcessPads:testReplacesPendingPatternWithThirdPad()
  setValue("device1", 3)
  state.set("device1.hostValue", 5)
  pressPad(87)
  lu.assertEquals(sentValue(), 7)
end

function TestProcessPads:testCyclesColourOfPendingPadWithShift()
  setValue("device1", 3)
  state.set("device1.hostValue", 5)
  state.shift()
  pressPad(85)
  lu.assertEquals(state.get "device1.colour5", colours.red.vibrant)
end

function TestProcessPads:testCyclesColourOfPlayingPadWithShiftWhileSwitchIsPending()
  setValue("device1", 3)
  state.set("device1.hostValue", 5)
  state.shift()
  pressPad(83)
  lu.assertEquals(state.get "device1.colour3", colours.red.vibrant)
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end
