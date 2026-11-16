local const = require "src.lpcommon.config.constants"
local items = require "src.lpcommon.config.items"
local launchnik = require "src.lpcommon.lib.launchnik._"
local state = require "src.lpcommon.lib.state._"
local surface = require "src.lpcommon.lib.surface._"
local setLaunchnik = require "src.lpcommon.remote.setState.launchnik"
local setTransport = require "src.lpcommon.remote.setState.transport"
local makeProcessSurface = require "src.lpcommon.remote.processMidi.surface"
local makeDeliverSurface = require "src.lpcommon.remote.deliverMidi.surface"
local defineItemIndices = require "test.lpcommon.defineItemIndices"
local receiveMidi = require "test.lpcommon.receiveMidi"
local sendOf = require "test.lpcommon.sendOf"

-- makes what a test needs to drive the codec of the device given from the
-- outside: with the MIDI the surface sends and gets, and what the host
-- reports and is told
return function(device)
  local processSurface = makeProcessSurface(device)
  local deliverSurface = makeDeliverSurface(device)

  local harness = {}

  -- puts the codec back to what it is when loaded, with nothing to deliver
  function harness.reset()
    remote.clearMocks()
    defineItemIndices()
    setLaunchnik.forgetItemIndices()
    launchnik.state.reset()
    state.setShifted(false)
    surface.makeShiftLayer(device).reset()
    for _, path in ipairs({ "transport.playing", "transport.recording" }) do
      state.set(path, false)
      state.update(path)
    end
  end

  -- simulates the pad at the place given being pressed, or let go with
  -- velocity 0
  function harness.pad(place, velocity)
    local status, number = sendOf(device, place)
    return receiveMidi(processSurface, status, number, velocity)
  end

  -- simulates the button at the place given being pressed, or let go with
  -- value 0
  harness.button = harness.pad

  function harness.holdShift(held)
    harness.button(device.controls.shift, held and 127 or 0)
  end

  -- simulates the host reporting new values for the named items
  function harness.report(values)
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
    setTransport(changed)
  end

  -- the MIDI events the surface gets
  function harness.deliver()
    return deliverSurface(const.ports.surface)
  end

  -- what the host has been told since the mocks were last cleared
  function harness.handledInputs()
    local inputs = {}
    for _, call in ipairs(remote.mock "handle_input".calls) do
      table.insert(inputs, call[1])
    end
    return inputs
  end

  return harness
end
