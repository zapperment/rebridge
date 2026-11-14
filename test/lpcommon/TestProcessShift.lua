local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lpcommon.lib.state._"
local makeProcessShift = require "src.lpcommon.remote.processMidi.shift"

-- defines the test class TestProcessShift<suffix> for the device given (see
-- src/lppmk3/device.lua)
return function(device, suffix)
  local TestProcessShift = {}
  _G["TestProcessShift" .. suffix] = TestProcessShift

  local processShift = makeProcessShift(device)

  local c = device.controls

  -- simulates the given button being pressed, or let go with value 0, as
  -- remote/processMidi/surface.lua hands it on
  local function receive(control, value)
    return processShift({ time_stamp = 0, control = control, value = value, pad = false })
  end

  function TestProcessShift:setUp()
    remote.clearMocks()
    state.setShifted(false)
  end

  function TestProcessShift:tearDown()
    state.setShifted(false)
  end

  function TestProcessShift:testPressingShiftShifts()
    lu.assertTrue(receive(c.shift, 127), "expected the Shift press to be processed")
    lu.assertTrue(state.isShifted())
  end

  function TestProcessShift:testReleasingShiftUnshifts()
    receive(c.shift, 127)
    lu.assertTrue(receive(c.shift, 0), "expected the Shift release to be processed")
    lu.assertFalse(state.isShifted())
  end

  function TestProcessShift:testIgnoresOtherButtons()
    lu.assertFalse(receive(c.back, 127), "expected another button not to be processed")
    lu.assertFalse(state.isShifted())
  end
end
