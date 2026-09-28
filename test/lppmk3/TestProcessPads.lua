local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lppmk3.lib.state._"
local ctrl = require "src.lppmk3.config.controls"
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
    state.set(pattern .. ".colour", colours.white.bright)
    state.update(pattern .. ".hostValue")
    state.update(pattern .. ".colour")
  end
end

function TestProcessPads:testPatternsStartWhite()
  local StateManager = require "src.lppmk3.lib.state.StateManager"
  lu.assertEquals(StateManager:new():get "pattern1.colour", colours.white.bright)
end

function TestProcessPads:testSelectsPatternWithoutShift()
  lu.assertTrue(pressPad(61))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1)
  lu.assertEquals(calls[1][1].value, 3)
  lu.assertEquals(state.get "pattern1.colour", colours.white.bright)
end

function TestProcessPads:testCyclesColourOfPatternWithShift()
  state.shift()
  lu.assertTrue(pressPad(63))
  lu.assertEquals(state.get "pattern3.colour", colours.red.vibrant)
  pressPad(13)
  lu.assertEquals(state.get "pattern3.colour", colours.orange.vibrant)
  lu.assertEquals(state.get "pattern1.colour", colours.white.bright)
end

function TestProcessPads:testDoesNotSelectPatternWithShift()
  state.shift()
  pressPad(61)
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end
