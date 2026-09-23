local calc = require "src.lib.calc._"
local const = require "src.lcxl3.config.constants"
local interpolatedValues = require "src.lcxl3.config.interpolatedValues"
local deb = require "src.lib.debug._"

return function(deviceType, param, hostValue)
  local ivForDevice = interpolatedValues[deviceType]
  if (ivForDevice == nil) then
    return nil
  end
  local ivForParameter = ivForDevice[param]
  if (ivForParameter == nil) then
    return nil
  end
  local min = ivForParameter.min
  local max = ivForParameter.max
  local mode = ivForParameter.mode or const.interpolation.linear
  local decimals = ivForParameter.decimals or 0
  local suffix = ivForParameter.suffix or " "
  local scaled
  if mode == const.interpolation.bipolar then
    scaled = calc.scaleBipolar(hostValue, min, max)
  elseif mode == const.interpolation.linear then
    scaled = calc.scale(hostValue, min, max)
  elseif mode == const.interpolation.reciprocal then
    scaled = calc.scaleReciprocal(hostValue)
  else
    return nil -- unknown mode, let the caller fall back to the raw value
  end
  local retVal
  if scaled == math.huge then
    retVal = "inf" .. suffix
  else
    retVal = string.format("%." .. decimals .. "f", scaled) .. suffix
  end
  return retVal
end
