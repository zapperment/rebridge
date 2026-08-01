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
    debug.log("[lib.display.getLabel] textValue=" ..
      textValue .. ", value=" .. value .. ", deviceType=" .. deviceType .. " - no labels for device!")
    return nil
  end
  local labels = deviceLabels[paramName]
  if labels == nil then
    debug.log("[lib.display.getLabel] textValue=" ..
      textValue ..
      ", value=" .. value .. ", deviceType=" .. deviceType .. ", paramName=" .. paramName .. " - no labels for param!")
    return
  end
  local labelFromTextValue = labels[textValue]
  local labelFromValue = labels[value]
  debug.log("[lib.display.getLabel] textValue=" ..
    textValue ..
    ", value=" ..
    value ..
    ", deviceType=" ..
    deviceType .. ", paramName=" .. paramName .. ", label=" .. (labelFromTextValue or labelFromValue or "nil"))
  return labelFromTextValue or labelFromValue
end
