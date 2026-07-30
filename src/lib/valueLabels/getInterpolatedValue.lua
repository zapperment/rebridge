local interpolatedValues = require("src.config.interpolatedValues")
local debug = require("src.lib.debug._")

local function round(x)
  return math.floor(x + 0.5)
end

local function scale(x, min, max)
  return min + (x / 127) * (max - min)
end

local function scaleBipolar(x, min, max)
  if x < 64 then
    return min + (x / 64) * -min
  else
    return ((x - 64) / 63) * max
  end
end

return function(deviceType, paramName, value)
  local ivForDevice = interpolatedValues[deviceType]
  if (ivForDevice == nil) then
    return nil
  end
  local ivForParameter = ivForDevice[paramName]
  if (ivForParameter == nil) then
    return nil
  end
  local min = ivForParameter.min
  local max = ivForParameter.max
  local biolar = ivForParameter.bipolar
  local scaled
  if biolar then
    scaled = round(scaleBipolar(value, min, max))
  else
    scaled = round(scale(value, min, max))
  end
  return scaled
end
