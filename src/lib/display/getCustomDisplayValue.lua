local customDisplayValues = require "src.config.customDisplayValues"
local str = require "src.lib.string._"
local deb = require "src.lib.debug._"

-- looks up the device-specific display value configured (see
-- config/customDisplayValues) for a parameter's value; returns nil if none is defined,
-- leaving the caller to decide on a fallback
return function(deviceType, param, hostValue, hostTextValue)
  local logMe = false --param == "Matrix Mod1 Source"
  local displayValuesForDevice = customDisplayValues[deviceType]
  if displayValuesForDevice == nil then
    if logMe then
      deb.log(
        "[lib:display:getCustomDisplayValue] " ..
        "no display values found for device " .. str.serialise(deviceType) .. " - " ..
        "returning nil"
      )
    end
    return nil
  end
  local displayValuesForParam = displayValuesForDevice[param]
  if displayValuesForParam == nil then
    if logMe then
      deb.log(
        "[lib:display:getCustomDisplayValue] " ..
        "no display values found for device " .. str.serialise(deviceType) .. ", " ..
        "parameter " .. str.serialise(param) .. " - " ..
        "returning nil"
      )
    end
    return
  end
  local displayValueForHostTextValue = displayValuesForParam[hostTextValue]
  if logMe then
    deb.log(
      "[lib:display:getCustomDisplayValue] " ..
      "display value for host text value: " .. str.serialise(displayValueForHostTextValue)
    )
  end
  local displayValueForHostValue = displayValuesForParam[tostring(hostValue)]
  if logMe then
    deb.log(
      "[lib:display:getCustomDisplayValue] " ..
      "display value for host value: " .. str.serialise(displayValueForHostValue)
    )
  end
  return displayValueForHostTextValue or displayValueForHostValue
end
