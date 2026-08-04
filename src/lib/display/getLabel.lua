local valueLabels = require("src.config.valueLabels")
local deb = require("src.lib.debug._")

-- looks up the device-specific display label configured (see
-- config/valueLabels) for a parameter's value; returns nil if none is defined,
-- leaving the caller to decide on a fallback
return function(deviceType, paramName, itemState)
  local logMe = paramName == "Resonator Select"
  if logMe then
    deb.log("[lib:display:getLabel] deviceType=" .. deviceType)
  end
  local textValue = itemState.text_value
  if logMe then
    deb.log("[lib:display:getLabel] textValue=" .. textValue)
  end
  local value = tostring(itemState.value)
  if logMe then
    deb.log("[lib:display:getLabel] value=" .. value)
  end
  local deviceLabels = valueLabels[deviceType]
  if deviceLabels == nil then
    if logMe then
      deb.log("[lib:display:getLabel] no labels for this device type!")
    end
    return nil
  end
  if logMe then
    deb.log("[lib:display:getLabel] paramName=" .. paramName)
  end
  local labels = deviceLabels[paramName]
  if labels == nil then
    if logMe then
      deb.log("[lib:display:getLabel] no labels for this param!")
    end
    return
  end
  local labelFromTextValue = labels[textValue]
  if logMe then
    deb.log("[lib:display:getLabel] labelFromTextValue=" .. (labelFromTextValue or "nil"))
  end
  local labelFromValue = labels[value]
  if logMe then
    deb.log("[lib:display:getLabel] labelFromValue=" .. (labelFromValue or "nil"))
  end
  return labelFromTextValue or labelFromValue
end
