local paramColours = require("src.config.paramColours")
local cond = require("src.config.conditionals")
local str = require("src.lib.string._")
local deb = require("src.lib.debug._")
local state = require("src.lib.state._")

-- The name of the colour the LED of a control should have: the one its device
-- type gives the parameter it is mapped to (see config/paramColours), falling
-- back to the control's own default colour.
return function(deviceType, param, defaultColour)
  local logMe = false -- str.startsWith(param, "Mode ")
  if logMe then
    deb.log(
      "[lib.colour.getColourName] " ..
      "deviceType=" .. deviceType .. "; " ..
      "defaultColour=" .. defaultColour
    )
  end
  local deviceColours = paramColours[deviceType]
  if logMe then
    deb.log(
      "[lib.colour.getColourName] " ..
      (deviceColours and "has custom colours per device" or "no custom colours per device")
    )
  end
  local colour = nil
  if deviceColours and deviceColours[param] then
    colour = deviceColours[param]
    if logMe then
      deb.log(
        "[lib.colour.getColourName] " ..
        "custom colour per parameter: " .. colour
      )
    end
    return colour
  end
  local conditional = cond[deviceType]
  if not conditional then
    if logMe then
      deb.log(
        "[lib.colour.getColourName] " ..
        "no conditionials configured for this device, using default colour "
      )
    end
    return defaultColour
  end
  conditional = conditional[param]
  if not conditional then
    if logMe then
      deb.log(
        "[lib.colour.getColourName] " ..
        "no conditionials configured for this parameter, using default colour "
      )
    end
    return defaultColour
  end
  local colours = conditional.colours
  if not colours then
    if logMe then
      deb.log(
        "[lib.colour.getColourName] " ..
        "no conditionial colours configured for this parameter, using default colour "
      )
    end
    return defaultColour
  end
  local dependsOn = conditional.dependsOn
  if logMe then
    deb.log(
      "[lib.colour.getColourName] " ..
      "dependsOn=" .. dependsOn
    )
  end
  local dependsOnValue = state.getHostValue(dependsOn)
  if not dependsOnValue then
    if logMe then
      deb.log(
        "[lib.colour.getColourName] " ..
        "no value stored for depends on param, using default colour "
      )
    end
    return defaultColour
  end
  if logMe then
    deb.log(
      "[lib.colour.getColourName] " ..
      "dependsOnValue=" .. dependsOnValue
    )
  end
  colour = conditional.colours[tostring(dependsOnValue)]
  if not colour then
    if logMe then
      deb.log(
        "[lib.colour.getColourName] " ..
        "no colour defined for depends on value, using default colour "
      )
    end
    return defaultColour
  end
  if logMe then
    deb.log(
      "[lib.colour.getColourName] " ..
      "colour=" .. colour
    )
  end

  return colour
end
