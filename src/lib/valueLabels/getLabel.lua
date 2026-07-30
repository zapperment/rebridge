local valueLabels = require("src.config.valueLabels")
local debug = require("src.lib.debug._")

-- looks up the device-specific display label configured (see
-- config/valueLabels) for a parameter's value; returns nil if none is defined,
-- leaving the caller to decide on a fallback
return function(deviceType, paramName, itemState)
  local textValue = itemState.text_value
  local value = tostring(itemState.value)
  local deviceLabels = valueLabels[deviceType]
  if deviceLabels == nil then
    return nil
  end
  local labels = deviceLabels[paramName]
  if labels == nil then
    return
  end
  return labels[textValue] or labels[value]
end
