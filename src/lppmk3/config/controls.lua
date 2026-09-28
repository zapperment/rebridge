local const = require "src.lppmk3.config.constants"

local pads = {}
for i = 1, const.counts.pads do
  table.insert(pads, "pad" .. i)
end

local patterns = {}
for i = 1, const.counts.patterns do
  table.insert(patterns, "pattern" .. i)
end

return {
  pads = pads,
  patterns = patterns,
}
