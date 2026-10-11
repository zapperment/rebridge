local const = require "src.lppmk3.config.constants"
local deliverTransport = require "src.lppmk3.remote.deliverMidi.transport"
local deliverLaunchnik = require "src.lppmk3.remote.deliverMidi.launchnik"

-- called regularly by the codec, once for each of its ports, to update the
-- remote surface (Launchpad); the other ports get nothing
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
