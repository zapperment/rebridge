local test = require "test.lib._"
local lu = test.luaUnit
local items = require "src.lpcommon.config.items"
local launchnik = require "src.lpcommon.lib.launchnik._"
local surface = require "src.lpcommon.lib.surface._"
local makeHarness = require "test.lpcommon.surfaceHarness"
local makeProcessSurface = require "src.lpcommon.remote.processMidi.surface"
local receiveMidi = require "test.lpcommon.receiveMidi"
local sendOf = require "test.lpcommon.sendOf"

-- which numbers are pads
TestIsPad = {}

function TestIsPad:testThePadsAreNumbered11To88InRowsOfEight()
  local pads = 0
  for control = 0, 127 do
    if surface.isPad(control) then
      pads = pads + 1
    end
  end
  lu.assertEquals(pads, 64)
  for _, pad in ipairs({ 11, 18, 45, 81, 88 }) do
    lu.assertTrue(surface.isPad(pad), pad)
  end
  -- the scene buttons, the top row, the left-hand column and the rows
  -- beneath the grid
  for _, button in ipairs({ 1, 8, 10, 19, 20, 80, 89, 90, 91, 98, 99, 101, 108 }) do
    lu.assertFalse(surface.isPad(button), button)
  end
end

-- defines the test class TestSurfaceInput<suffix> for the device given (see
-- src/lppmk3/device.lua): how the MIDI of the surface becomes the inputs of
-- the codec's handlers
return function(device, suffix)
  local TestSurfaceInput = {}
  _G["TestSurfaceInput" .. suffix] = TestSurfaceInput

  local c = device.controls
  local state = launchnik.state
  local press = launchnik.press
  local harness = makeHarness(device)
  local processSurface = makeProcessSurface(device)
  local noteOff = 128
  local noteOn = 144
  local controlChange = 176

  function TestSurfaceInput:setUp()
    harness.reset()
  end

  function TestSurfaceInput:tearDown()
    harness.reset()
  end

  function TestSurfaceInput:testAPadSendsANote()
    lu.assertTrue(harness.pad(81, 127))
    lu.assertEquals(harness.handledInputs()[1], { time_stamp = 0, item = items.track1selection.index, value = 0 })
  end

  -- a pad that is let go may send a note off instead of a note on with
  -- velocity 0, and lets go of the relaunch press all the same
  function TestSurfaceInput:testNoteOffLetsGoOfAPad()
    state.present[press.buttonIndex(3, 5)] = true
    harness.pad(43, 127)
    remote.clearMocks()
    local _, number = sendOf(device, 43)
    lu.assertTrue(receiveMidi(processSurface, noteOff, number, 64))
    lu.assertEquals(harness.handledInputs(), { { time_stamp = 0, item = items.track3relaunch.index, value = 0 } })
    lu.assertEquals(state.heldRelaunches, {})
  end

  function TestSurfaceInput:testAButtonSendsAControlChange()
    lu.assertTrue(harness.button(c.fillIn, 127))
    lu.assertEquals(harness.handledInputs(), { { time_stamp = 0, item = items.fillin.index, value = 1 } })
  end

  function TestSurfaceInput:testShiftIsHeldForAsLongAsItsButtonIs()
    local shift = require "src.lpcommon.lib.state._"
    lu.assertTrue(harness.button(c.shift, 127))
    lu.assertTrue(shift.isShifted())
    lu.assertTrue(harness.button(c.shift, 0))
    lu.assertFalse(shift.isShifted())
    lu.assertEquals(harness.handledInputs(), {})
  end

  -- a control change with the number of a pad is not a press of it, nor is a
  -- note with the number of a button a press of that; a device that numbers
  -- its pads and buttons in its own way has its own tests for this
  function TestSurfaceInput:testOtherMidiIsLeftAlone()
    if not device.midi.placeOf then
      lu.assertFalse(receiveMidi(processSurface, controlChange, 81, 127))
      lu.assertFalse(receiveMidi(processSurface, noteOn, c.fillIn, 127))
      lu.assertFalse(receiveMidi(processSurface, noteOn, c.shift, 127))
    end
    -- polyphonic aftertouch
    lu.assertFalse(receiveMidi(processSurface, 160, 81, 127))
    remote.mock "match_midi":impl(function()
      return nil
    end)
    lu.assertFalse(processSurface({ time_stamp = 0, port = 1 }))
    lu.assertEquals(harness.handledInputs(), {})
  end
end
