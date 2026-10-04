local const = require "src.lppmk3.config.constants"
local deliverTransport = require "src.lppmk3.remote.deliverMidi.transport"

-- called regularly by the codec, once for each of its ports, to update the
-- remote surface (Launchpad); the other ports get nothing
return function(port)
  if port ~= const.ports.surface then
    return {}
  end
  return deliverTransport()
end
