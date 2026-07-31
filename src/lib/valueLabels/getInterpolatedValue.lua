local interpolatedValues = require("src.config.interpolatedValues")
local debug = require("src.lib.debug._")

local function round(value, decimals)
  local mult = 10 ^ (decimals or 0)
  local v = value * mult
  if v >= 0 then
    return math.floor(v + 0.5) / mult
  else
    return math.ceil(v - 0.5) / mult
  end
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
  local decimals = ivForParameter.decimals
  local scaled
  if biolar then
    scaled = round(scaleBipolar(value, min, max), decimals)
  else
    scaled = round(scale(value, min, max), decimals)
  end
  return scaled
end
