local test = require "test.lib._"
local lu = test.luaUnit
local items = require "src.lpp.config.items"
local colours = require "src.lpp.lib.colour.config"
local launchnik = require "src.lpp.lib.launchnik._"
local shift = require "src.lpp.lib.state._"
local setLaunchnik = require "src.lpp.remote.setState.launchnik"
local makeDeliverLaunchnik = require "src.lpp.remote.deliverMidi.launchnik"
local makeProcessLaunchnik = require "src.lpp.remote.processMidi.launchnik"
local device = require "src.lppmk2.device"
local defineItemIndices = require "test.lpp.defineItemIndices"

-- The Launchpad Pro [MK2] has one row of buttons beneath the grid, control
-- changes 1 to 8: the function buttons. With Shift held, the buttons of that
-- row printed Mute (3), Solo (4) and Stop Clip (8) are the function select
-- buttons, and the row shows their lights instead.
TestFunctionSelectMK2 = {}

local state = launchnik.state
local press = launchnik.press
local makeColourEvent = device.midi.makeColourEvent
local deliverLaunchnik = makeDeliverLaunchnik(device)
local processLaunchnik = makeProcessLaunchnik(device)
local controlChange = 176

local function report(values)
  local byIndex = {}
  local changed = {}
  for name, value in pairs(values) do
    byIndex[items[name].index] = value
    table.insert(changed, items[name].index)
  end
  remote.mock "get_item_state":impl(function(index)
    return { is_enabled = true, value = byIndex[index] }
  end)
  setLaunchnik.setState(changed)
end

local function receive(data1, data2)
  remote.mock "match_midi":impl(function()
    return { x = controlChange, y = data1, z = data2 }
  end)
  return processLaunchnik.processPadsAndTrackButtons({ time_stamp = 0 })
end

local function handledInputs()
  local inputs = {}
  for _, call in ipairs(remote.mock "handle_input".calls) do
    table.insert(inputs, call[1])
  end
  return inputs
end

-- the row as it shows the function select buttons, while stop is chosen
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

function TestFunctionSelectMK2:setUp()
  remote.clearMocks()
  defineItemIndices()
  setLaunchnik.forgetItemIndices()
  state.reset()
  shift.setShifted(false)
end

function TestFunctionSelectMK2:tearDown()
  state.reset()
  shift.setShifted(false)
  setLaunchnik.forgetItemIndices()
end

function TestFunctionSelectMK2:testWithoutShiftTheRowIsTheFunctionButtons()
  state.present[press.buttonIndex(3, 1)] = true
  state["function"] = press.functionMute
  receive(3, 127)
  lu.assertEquals(handledInputs(), { { time_stamp = 0, item = items.track3mute.index, value = 1 } })
end

function TestFunctionSelectMK2:testWithShiftMuteSoloAndStopClipChooseTheFunction()
  state.present[press.buttonIndex(3, 1)] = true
  shift.setShifted(true)
  for control, func in pairs({ [3] = press.functionMute, [4] = press.functionSolo, [8] = press.functionStop }) do
    remote.clearMocks()
    lu.assertTrue(receive(control, 127))
    lu.assertEquals(handledInputs(), { { time_stamp = 0, item = items["function"].index, value = func } })
  end
  remote.clearMocks()
  lu.assertTrue(receive(1, 127))
  lu.assertEquals(handledInputs(), {})
end

-- a function button pressed before Shift is let go of as it was pressed
function TestFunctionSelectMK2:testShiftDoesNotKeepAFunctionButtonHeld()
  state.present[press.buttonIndex(3, 1)] = true
  state["function"] = press.functionSolo
  receive(3, 127)
  shift.setShifted(true)
  remote.clearMocks()
  lu.assertTrue(receive(3, 0))
  lu.assertEquals(handledInputs(), { { time_stamp = 0, item = items.track3solo.index, value = 0 } })
end

function TestFunctionSelectMK2:testRowShowsTheFunctionSelectButtonsWhileShiftIsHeld()
  report { setup = 0, track1functionlight = 2, track3functionlight = 1 }
  local events = deliverLaunchnik()
  lu.assertEquals({ events[1], events[2] }, {
    makeColourEvent(1, colours.red.vibrant),
    makeColourEvent(3, colours.red.dim),
  })

  shift.setShifted(true)
  lu.assertEquals(deliverLaunchnik(), functionSelectRow(colours.white.dim, colours.white.dim, colours.red.vibrant))
  lu.assertEquals(deliverLaunchnik(), {})

  -- a new function shows on the function select buttons while Shift is held
  report { ["function"] = press.functionSolo }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(4, colours.blue.vibrant),
    makeColourEvent(8, colours.white.dim),
  })

  -- a function light that changes meanwhile waits for Shift to be let go
  report { track2functionlight = 2 }
  lu.assertEquals(deliverLaunchnik(), {})

  shift.setShifted(false)
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(1, colours.blue.vibrant),
    makeColourEvent(2, colours.blue.vibrant),
    makeColourEvent(3, colours.blue.dim),
    makeColourEvent(4, colours.off),
    makeColourEvent(5, colours.off),
    makeColourEvent(6, colours.off),
    makeColourEvent(7, colours.off),
    makeColourEvent(8, colours.off),
  })
  lu.assertEquals(deliverLaunchnik(), {})
end

function TestFunctionSelectMK2:testRowIsDarkWithShiftWhileNoLaunchnikIsMapped()
  shift.setShifted(true)
  lu.assertEquals(deliverLaunchnik(), functionSelectRow(colours.off, colours.off, colours.off))
end
