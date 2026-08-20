local paramColours = require "src.config.paramColours"
local cond = require "src.config.conditionals"
local deb = require "src.lib.debug._"
local state = require "src.lib.state._"

-- The colour a conditional (or one of its overrides) gives for the current
-- value of the parameter it depends on. Returns nil when that parameter has no
-- value stored yet or the colours table says nothing about the current one.
local function getColourForDependency(conditional)
  if not conditional.colours then
    return nil
  end
  local dependsOnValue = state.getHostValue(conditional.dependsOn)
  if dependsOnValue == nil then
    return nil
  end
  -- two-valued parameters are stored as booleans
  -- (see src/remote/setState/buttons.lua)
  if type(dependsOnValue) == "boolean" then
    dependsOnValue = dependsOnValue and 127 or 0
  end
  return conditional.colours[tostring(dependsOnValue)]
end

-- The name of the colour the LED of a control should have: the one its device
-- type gives the parameter it is mapped to (see config/paramColours), falling
-- back to the control's own default colour.
return function(deviceType, param, defaultColour)
  local logMe = false
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
  if logMe then
    deb.log(
      "[lib.colour.getColourName] " ..
      "dependsOn=" .. conditional.dependsOn
    )
  end
  -- a parameter can depend on more than one other parameter: an override takes
  -- a second parameter into account and wins over the parameter's own colours
  -- as soon as it has something to say about that parameter's current value
  for _, override in ipairs(conditional.overrides or {}) do
    local overrideColour = getColourForDependency(override)
    if overrideColour then
      if logMe then
        deb.log(
          "[lib.colour.getColourName] " ..
          "overridden by " .. override.dependsOn .. ": " .. overrideColour
        )
      end
      return overrideColour
    end
  end
  colour = getColourForDependency(conditional)
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
