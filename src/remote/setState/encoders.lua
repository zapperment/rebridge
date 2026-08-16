local const = require("src.config.constants")
local util = require("src.remote.setState.util._")
local deb = require("src.lib.debug._")

-- handles changes of the encoders of the host (Reason)
return function(hostItems)
  for _, hostItemIndex in ipairs(hostItems) do
    for i = 1, const.counts.encoders do
      local control = "encoder" .. i
      util.set(hostItemIndex, control)
    end
  end
end
