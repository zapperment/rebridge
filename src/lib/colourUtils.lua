  local function hexToRgb(hex)
    local num = tonumber(hex, 16)
    local r = math.floor(num / 65536) % 256
    local g = math.floor(num / 256) % 256
    local b = num % 256
    return r, g, b
  end

  local function rgbToHsb(r, g, b)
    r = r / 255
    g = g / 255
    b = b / 255
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min

    local h = 0
    if delta ~= 0 then
      if max == r then
        h = 60 * (((g - b) / delta) % 6)
      elseif max == g then
        h = 60 * ((b - r) / delta + 2)
      else
        h = 60 * ((r - g) / delta + 4)
      end
    end
    if h < 0 then h = h + 360 end

    local s = 0
    if max ~= 0 then s = delta / max end

    return h, s, max
  end

  local function hsbToRgb(h, s, b)
    local c = b * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = b - c

    local r1, g1, b1
    if h < 60 then
      r1, g1, b1 = c, x, 0
    elseif h < 120 then
      r1, g1, b1 = x, c, 0
    elseif h < 180 then
      r1, g1, b1 = 0, c, x
    elseif h < 240 then
      r1, g1, b1 = 0, x, c
    elseif h < 300 then
      r1, g1, b1 = x, 0, c
    else
      r1, g1, b1 = c, 0, x
    end

    return
        math.floor((r1 + m) * 255 + 0.5),
        math.floor((g1 + m) * 255 + 0.5),
        math.floor((b1 + m) * 255 + 0.5)
  end

  local function to7Bit(v)
    return math.floor((v * 127 / 255) + 0.5)
  end

-- Computes a 7-bit RGB sysex colour string for a Launch Control style
-- controller, given a base colour and a 0-127 value.
--
-- value = 0    -> B at 5% of the original brightness
-- value = 95   -> original colour, unchanged
-- value = 1-94 -> B interpolated between the 0 and 95 cases
-- value = 127  -> S at 70% of the original saturation (B unchanged)
-- value = 96-126 -> S interpolated between the 95 and 127 cases

local function getColourForValue(hex, value)
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

return {
  getColourForValue = getColourForValue
}
