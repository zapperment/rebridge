local const = require "src.lpcommon.config.constants"
local surface = require "src.lpcommon.lib.surface._"
local makeDeliverTransport = require "src.lpcommon.remote.deliverMidi.transport"
local makeDeliverLaunchnik = require "src.lpcommon.remote.deliverMidi.launchnik"

-- makes what the codec calls regularly, once for each of its ports, to update
-- the remote surface (Launchpad) given (see src/lppmk3/device.lua); the other
-- ports get nothing. The lights of the controls become the MIDI events of the
-- pads and buttons that show them on their way through the Shift layer.
return function(device)
  local shiftLayer = surface.makeShiftLayer(device)
  local deliverTransport = makeDeliverTransport(device)
  local deliverLaunchnik = makeDeliverLaunchnik(device)

  return function(port)
    if port ~= const.ports.surface then
      return {}
    end
    local lights = deliverTransport()
    for _, light in ipairs(deliverLaunchnik()) do
      table.insert(lights, light)
    end
    return shiftLayer.deliver(lights)
  end
end
