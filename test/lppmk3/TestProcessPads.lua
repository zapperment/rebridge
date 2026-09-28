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
  for _, pattern in ipairs(ctrl.patterns) do
    state.set(pattern .. ".hostValue", 0)
    state.update(pattern .. ".hostValue")
    for value = 1, const.counts.patternValues do
      state.set(pattern .. ".colour" .. value, colours.white.dim)
      state.update(pattern .. ".colour" .. value)
    end
  end
end

function TestProcessPads:testPatternValuesStartWhite()
  local StateManager = require "src.lppmk3.lib.state.StateManager"
  local stateManager = StateManager:new()
  for value = 1, const.counts.patternValues do
    lu.assertEquals(stateManager:get("pattern1.colour" .. value), colours.white.dim)
  end
end

function TestProcessPads:testSelectsPatternWithoutShift()
  lu.assertTrue(pressPad(61))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1)
  lu.assertEquals(calls[1][1].value, 3)
  lu.assertEquals(state.get "pattern1.colour3", colours.white.dim)
end

function TestProcessPads:testCyclesColourOfLitPadWithShift()
  state.set("pattern3.hostValue", 3)
  state.shift()
  lu.assertTrue(pressPad(63))
  lu.assertEquals(state.get "pattern3.colour3", colours.red.vibrant)
  pressPad(63)
  lu.assertEquals(state.get "pattern3.colour3", colours.orange.vibrant)
end

function TestProcessPads:testCyclesOnlyColourOfTappedValue()
  state.set("pattern3.hostValue", 3)
  state.shift()
  pressPad(63)
  for value = 1, const.counts.patternValues do
    if value ~= 3 then
      lu.assertEquals(state.get("pattern3.colour" .. value), colours.white.dim)
    end
  end
  lu.assertEquals(state.get "pattern1.colour3", colours.white.dim)
end

function TestProcessPads:testDoesNothingWithShiftOnUnlitPad()
  state.set("pattern3.hostValue", 3)
  state.shift()
  lu.assertTrue(pressPad(13))
  lu.assertEquals(state.get "pattern3.colour8", colours.white.dim)
  lu.assertEquals(state.get "pattern3.colour3", colours.white.dim)
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessPads:testDoesNothingWithShiftWhenNoPadIsLit()
  state.shift()
  pressPad(63)
  lu.assertEquals(state.get "pattern3.colour3", colours.white.dim)
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessPads:testDoesNotSelectPatternWithShift()
  state.set("pattern1.hostValue", 3)
  state.shift()
  pressPad(61)
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end
