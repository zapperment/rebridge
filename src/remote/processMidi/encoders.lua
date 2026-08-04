local const = require("src.config.constants")
local state = require("src.lib.state._")
local col = require("src.lib.colour._")
local util = require("src.remote.processMidi.util._")
local deb = require("src.lib.debug._")

-- handles changes of the encoders of the remote surface (Launch Control)
return function(event)
  for i = 1, const.counts.encoders do
    if util.process(
          "encoder" .. i,
          event,
          function(control, controlSurfaceValue, item)
            local colourName = col.getColourName(
              state.getNext("deviceType"),
              remote.get_item_name(item.index),
              item.colour
            )
            state.set(control .. ".colour", col.getColour(colourName, controlSurfaceValue))
            if control == "encoder4" then
              deb.log(
                "[remote:processMidi:encoders] " ..
                "next " .. control .. ".colour=" ..
                col.getColour(colourName, controlSurfaceValue) ..
                " (" .. colourName .. " " .. controlSurfaceValue .. ")"
              )
            end

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
