local ctrl = require "src.lppmk3.config.controls"
local deb = require "src.lib.debug._"

-- handles changes of the patterns of the host (Reason)
return function(hostItems)
  for _, hostItemIndex in ipairs(hostItems) do
    for _, control in ipairs(ctrl.pads) do
      local logMe = control == "pad1"
      if logMe then
        deb.log(
          "[lppmk3.setState.patterns] " ..
          "control=" .. control
        )
      end
    end
  end
end
