local const = require("src.config.constants")
local util = require("src.remote.processMidi.util._")
local deb = require("src.lib.debug._")

local controls = {}
for i = 1, const.counts.encoders do
  table.insert(controls, "encoder" .. i)
  table.insert(controls, "encoder" .. i .. "alt")
end

-- handles changes of the encoders of the remote surface (Launch Control)
return function(event)
  local processed = false
  for _, control in ipairs(controls) do
    processed = util.process(
      control,
      event,
      function(controlSurfaceValue, item)
        -- update host (Reason)
        remote.handle_input({
          time_stamp = event.time_stamp,
          item = item.index,
          value = controlSurfaceValue
        })
      end
    ) or processed
  end
  return processed
end
