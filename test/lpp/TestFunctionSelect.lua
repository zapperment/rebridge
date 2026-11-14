local test = require "test.lib._"
local lu = test.luaUnit
local items = require "src.lpcommon.config.items"
local colours = require "src.lpcommon.lib.colour.config"
local launchnik = require "src.lpcommon.lib.launchnik._"
local device = require "src.lpp.device"
local makeHarness = require "test.lpcommon.surfaceHarness"

-- The Launchpad Pro has one row of buttons beneath the grid, control
-- changes 1 to 8: the function buttons. With Shift held, the buttons of that
-- row printed Mute (3), Solo (4) and Stop Clip (8) are the function select
-- buttons, and the row shows their lights instead.
TestFunctionSelectLPP = {}

local state = launchnik.state
local press = launchnik.press
local makeColourEvent = device.midi.makeColourEvent
local surface = makeHarness(device)

-- the row as it shows the function select buttons
local function functionSelectRow(mute, solo, stop)
  return {
    makeColourEvent(1, colours.off),
    makeColourEvent(2, colours.off),
    makeColourEvent(3, mute),
    makeColourEvent(4, solo),
    makeColourEvent(5, colours.off),
    makeColourEvent(6, colours.off),
    makeColourEvent(7, colours.off),
    makeColourEvent(8, stop),
  }
end

function TestFunctionSelectLPP:setUp()
  surface.reset()
end

function TestFunctionSelectLPP:tearDown()
  surface.reset()
end

function TestFunctionSelectLPP:testWithoutShiftTheRowIsTheFunctionButtons()
  state.present[press.buttonIndex(3, 1)] = true
  state["function"] = press.functionMute
  surface.button(3, 127)
  lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.track3mute.index, value = 1 } })
end

function TestFunctionSelectLPP:testWithShiftMuteSoloAndStopClipChooseTheFunction()
  state.present[press.buttonIndex(3, 1)] = true
  surface.holdShift(true)
  for control, func in pairs({ [3] = press.functionMute, [4] = press.functionSolo, [8] = press.functionStop }) do
    remote.clearMocks()
    lu.assertTrue(surface.button(control, 127))
    lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items["function"].index, value = func } })
    remote.clearMocks()
    surface.button(control, 0)
    lu.assertEquals(surface.handledInputs(), {})
  end
  -- the other buttons of the row do nothing
  remote.clearMocks()
  lu.assertTrue(surface.button(1, 127))
  lu.assertTrue(surface.button(1, 0))
  lu.assertEquals(surface.handledInputs(), {})
end

-- a function button pressed before Shift is let go of as it was pressed
function TestFunctionSelectLPP:testShiftDoesNotKeepAFunctionButtonHeld()
  state.present[press.buttonIndex(3, 1)] = true
  state["function"] = press.functionSolo
  surface.button(3, 127)
  surface.holdShift(true)
  remote.clearMocks()
  lu.assertTrue(surface.button(3, 0))
  lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.track3solo.index, value = 0 } })
end

-- nor does letting go of Shift make a function select button let go of a
-- function button
function TestFunctionSelectLPP:testAFunctionSelectButtonIsLetGoOfAsOne()
  state.present[press.buttonIndex(3, 1)] = true
  state["function"] = press.functionMute
  surface.holdShift(true)
  surface.button(3, 127)
  surface.holdShift(false)
  remote.clearMocks()
  surface.button(3, 0)
  lu.assertEquals(surface.handledInputs(), {})
end

function TestFunctionSelectLPP:testRowShowsTheFunctionSelectButtonsWhileShiftIsHeld()
  surface.report { setup = 0, track1functionlight = 2, track3functionlight = 1 }
  local events = surface.deliver()
  lu.assertEquals({ events[1], events[2] }, {
    makeColourEvent(1, colours.red.vibrant),
    makeColourEvent(3, colours.red.dim),
  })

  surface.holdShift(true)
  lu.assertEquals(surface.deliver(), functionSelectRow(colours.white.dim, colours.white.dim, colours.red.vibrant))
  lu.assertEquals(surface.deliver(), {})

  -- a new function shows on the function select buttons while Shift is held
  surface.report { ["function"] = press.functionSolo }
  lu.assertEquals(surface.deliver(), {
    makeColourEvent(4, colours.blue.vibrant),
    makeColourEvent(8, colours.white.dim),
  })

  -- a function light that changes meanwhile waits for Shift to be let go
  surface.report { track2functionlight = 2 }
  lu.assertEquals(surface.deliver(), {})

  surface.holdShift(false)
  lu.assertEquals(surface.deliver(), {
    makeColourEvent(1, colours.blue.vibrant),
    makeColourEvent(2, colours.blue.vibrant),
    makeColourEvent(3, colours.blue.dim),
    makeColourEvent(4, colours.off),
    makeColourEvent(5, colours.off),
    makeColourEvent(6, colours.off),
    makeColourEvent(7, colours.off),
    makeColourEvent(8, colours.off),
  })
  lu.assertEquals(surface.deliver(), {})
end

function TestFunctionSelectLPP:testRowIsDarkWithShiftWhileNoLaunchnikIsMapped()
  surface.holdShift(true)
  lu.assertEquals(surface.deliver(), functionSelectRow(colours.off, colours.off, colours.off))
end
