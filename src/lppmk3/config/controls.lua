local const = require "src.lppmk3.config.constants"

local pads = {}
for i = 1, const.counts.pads do
  table.insert(pads, "pad" .. i)
end

return {
  pads = pads,
}
