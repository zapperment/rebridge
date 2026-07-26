local valueLabels = require("src.config.valueLabels")

-- looks up the device-specific display label configured (see
-- config/valueLabels) for a parameter's value; returns nil if none is defined,
-- leaving the caller to decide on a fallback
return function(deviceType, paramName, textValue)
  local deviceLabels = valueLabels[deviceType]
  local labels = deviceLabels and deviceLabels[paramName]
  return labels and labels[textValue]
end
