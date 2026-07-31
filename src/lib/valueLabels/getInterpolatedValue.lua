local interpolatedValues = require("src.config.interpolatedValues")
local calc = require("src.lib.calc._")
local const = require("src.config.constants")
local debug = require("src.lib.debug._")

return function(deviceType, paramName, value)
  local ivForDevice = interpolatedValues[deviceType]
  if (ivForDevice == nil) then
    debug.log("[lib.valueLabels.getInterpolatedValue] deviceType=" ..
      deviceType .. " - no interpolated values for this device")
    return nil
  end
  local ivForParameter = ivForDevice[paramName]
  if (ivForParameter == nil) then
    debug.log("[lib.valueLabels.getInterpolatedValue] deviceType=" ..
      deviceType .. ", paramName=" .. paramName .. " - no interpolated values for this param")
    return nil
  end
  local min = ivForParameter.min
  local max = ivForParameter.max
  local mode = ivForParameter.mode or const.interpolation.linear
  local decimals = ivForParameter.decimals or 0
  local suffix = ivForParameter.suffix or " "
  local scaled
  debug.log("[lib.valueLabels.getInterpolatedValue] deviceType=" ..
    deviceType ..
    ", paramName=" ..
    paramName .. ", min=" .. min .. ", max=" .. max .. ", mode=" .. mode ..
    ", decimals=" .. decimals .. ", suffix=" .. suffix)
  if mode == const.interpolation.bipolar then
    debug.log("[lib.valueLabels.getInterpolatedValue] => scaling in bipolar mode")
    scaled = calc.scaleBipolar(value, min, max)
  elseif mode == const.interpolation.linear then
    debug.log("[lib.valueLabels.getInterpolatedValue] => scaling in linear mode")
    scaled = calc.scale(value, min, max)
  elseif mode == const.interpolation.reciprocal then
    debug.log("[lib.valueLabels.getInterpolatedValue] => scaling in reciprocal mode")
    scaled = calc.scaleReciprocal(value)
  else
    debug.log("[lib.valueLabels.getInterpolatedValue] => unknown mode, no scaling")
    return nil -- unknown mode, let the caller fall back to the raw value
  end
  local retVal
  if scaled == math.huge then
    retVal = "inf" .. suffix
  else
    retVal = string.format("%." .. decimals .. "f", scaled) .. suffix
  end
  debug.log("[lib.valueLabels.getInterpolatedValue] => return value: " .. retVal)
  return retVal
end
