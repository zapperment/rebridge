local hexToRgb = require("src.utils.colour.hexToRgb")
local rgbToHsb = require("src.utils.colour.rgbToHsb")
local hsbToRgb = require("src.utils.colour.hsbToRgb")
local to7Bit = require("src.utils.colour.to7Bit")

return function(hex, value)
  local r, g, b = hexToRgb(hex)
  local h, s, brightness = rgbToHsb(r, g, b)

  local newS, newB = s, brightness

  if value <= 95 then
    local t = value / 95
    newB = brightness * (0.05 + 0.95 * t)
  else
    local t = (value - 95) / 32
    newS = s * (1 - 0.3 * t)
  end

  local nr, ng, nb = hsbToRgb(h, newS, newB)
  return string.format("%02x %02x %02x", to7Bit(nr), to7Bit(ng), to7Bit(nb))
end
