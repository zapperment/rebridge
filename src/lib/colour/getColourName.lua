local paramColours = require("src.config.paramColours")

-- The name of the colour the LED of a control should have: the one its device
-- type gives the parameter it is mapped to (see config/paramColours), falling
-- back to the control's own default colour.
return function(deviceType, paramName, defaultColour)
  local deviceColours = paramColours[deviceType]
  return deviceColours and deviceColours[paramName] or defaultColour
end
