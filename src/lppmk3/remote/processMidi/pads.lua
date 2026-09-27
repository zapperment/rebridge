local ctrl = require "src.lppmk3.config.controls"
local deb = require "src.lib.debug._"

-- handles changes of the buttons of the remote surface (Launchpad)
return function(event)
  local processed = false
  for _, control in ipairs(ctrl.pads) do
    local logMe = control == "pad1"
    if logMe then
      deb.log(
        "[lppmk3.processMidi.padColours] " ..
        "control=" .. control
      )
    end
  end
  return processed
end
