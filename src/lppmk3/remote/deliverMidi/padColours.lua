local deb = require "src.lib.debug._"
local ctrl = require "src.lppmk3.config.controls"

-- called regularly by the codec to update the remote surface (Launchpad)
return function()
  local events = {}
  for _, control in ipairs(ctrl.pads) do
    local logMe = control == "pad1"
    if logMe then
      deb.log(
        "[lppmk3.deliverMidi.pads] " ..
        "control=" .. control
      )
    end
  end
  return events
end
