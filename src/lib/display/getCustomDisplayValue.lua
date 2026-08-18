local customDisplayValues = require "src.config.customDisplayValues"
local deb = require "src.lib.debug._"

-- looks up the device-specific display value configured (see
-- config/customDisplayValues) for a parameter's value; returns nil if none is defined,
-- leaving the caller to decide on a fallback
return function(deviceType, param, hostValue, hostTextValue)
  local displayValuesForDevice = customDisplayValues[deviceType]
  if displayValuesForDevice == nil then
    return nil
  end
  local displayValuesForParam = displayValuesForDevice[param]
  if displayValuesForParam == nil then
    return
  end
  local displayValueForHostTextValue = displayValuesForParam[hostTextValue]
  local displayValueForHostValue = displayValuesForParam[tostring(hostValue)]
  return displayValueForHostTextValue or displayValueForHostValue
end
