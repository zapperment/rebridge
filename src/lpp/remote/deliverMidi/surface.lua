local const = require "src.lpp.config.constants"
local makeDeliverTransport = require "src.lpp.remote.deliverMidi.transport"
local makeDeliverLaunchnik = require "src.lpp.remote.deliverMidi.launchnik"

-- makes what the codec calls regularly, once for each of its ports, to update
-- the remote surface (Launchpad) given (see src/lppmk3/device.lua); the other
-- ports get nothing
return function(device)
  local deliverTransport = makeDeliverTransport(device)
  local deliverLaunchnik = makeDeliverLaunchnik(device)

  return function(port)
    if port ~= const.ports.surface then
      return {}
    end
    local events = deliverTransport()
    for _, event in ipairs(deliverLaunchnik()) do
      table.insert(events, event)
    end
    return events
  end
end
