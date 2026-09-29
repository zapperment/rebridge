local const = require "src.lppmk3.config.constants"

local pads = {}
for i = 1, const.counts.pads do
  table.insert(pads, "pad" .. i)
end

local devices = {}
for i = 1, const.counts.devices do
  table.insert(devices, "device" .. i)
end

return {
  pads = pads,
  devices = devices,
}
