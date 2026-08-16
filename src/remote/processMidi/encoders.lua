local const = require("src.config.constants")
local util = require("src.remote.processMidi.util._")
local deb = require("src.lib.debug._")

-- handles changes of the encoders of the remote surface (Launch Control)
return function(event)
  for i = 1, const.counts.encoders do
    if util.process(
          "encoder" .. i,
          event,
          function(_, controlSurfaceValue, item)
            -- update host (Reason)
            remote.handle_input({
              time_stamp = event.time_stamp,
              item = item.index,
              value = controlSurfaceValue
            })
          end
        ) then
      return true
    end
  end
  return false
end
