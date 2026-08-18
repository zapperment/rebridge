local const = require("src.config.constants")
local util = require("src.remote.setState.util._")
local deb = require("src.lib.debug._")

local controls = {}
for i = 1, const.counts.encoders do
  table.insert(controls, "encoder" .. i)
  table.insert(controls, "encoder" .. i .. "alt")
end

-- handles changes of the encoders of the host (Reason)
return function(hostItems)
  for _, hostItemIndex in ipairs(hostItems) do
    for _, control in ipairs(controls) do
      util.set(hostItemIndex, control)
    end
  end
end
