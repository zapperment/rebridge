local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lppmk3.lib.state._"
local processShift = require "src.lppmk3.remote.processMidi.shift"

TestProcessShift = {}

-- Shift sends CC 90 on channel 1
local shiftMidi = "b0 5a xx"

-- simulates the remote surface sending a CC, with the mocked remote.match_midi
-- matching on the pattern string alone
local function receive(pattern, value)
  remote.mock "match_midi":impl(function(midi)
    if midi == pattern then
      return { x = value }
    end
    return nil
  end)
  return processShift({ time_stamp = 0 })
end

function TestProcessShift:setUp()
  remote.clearMocks()
  state.setShifted(false)
end

function TestProcessShift:testPressingShiftShifts()
  lu.assertTrue(receive(shiftMidi, 127), "expected the Shift press to be processed")
  lu.assertTrue(state.isShifted())
end

function TestProcessShift:testReleasingShiftUnshifts()
  receive(shiftMidi, 127)
  lu.assertTrue(receive(shiftMidi, 0), "expected the Shift release to be processed")
  lu.assertFalse(state.isShifted())
end

function TestProcessShift:testIgnoresOtherMidi()
  lu.assertFalse(receive("90 xx yy", 127), "expected other MIDI not to be processed")
  lu.assertFalse(state.isShifted())
end
