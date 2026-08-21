local ctrl = require "src.config.controls"
local util = require "src.remote.setState.util._"
local deb = require "src.lib.debug._"

-- handles changes of the encoders of the host (Reason)
return function(hostItems)
  for _, hostItemIndex in ipairs(hostItems) do
    for _, control in ipairs(ctrl.rackUIs) do
      util.set(hostItemIndex, control)
    end
  end
end
