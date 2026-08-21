local paramColours = require "src.config.paramColours"
local condi = require "src.lib.conditional._"
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
  -- a parameter can have more than one conditional, in which case the first one
  -- that has a colour for the current value of the parameter it depends on wins
  for _, conditional in ipairs(condi.getConditionals(deviceType, param)) do
    if logMe then
      deb.log(
        "[lib.colour.getColourName] " ..
        "dependsOn=" .. conditional.dependsOn
      )
    end
    -- a conditional can take a second parameter into account: an override wins
    -- over the conditional's own colours as soon as it has something to say
    -- about that parameter's current value
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
    if colour then
      if logMe then
        deb.log(
          "[lib.colour.getColourName] " ..
          "colour=" .. colour
        )
      end
      return colour
    end
  end
  if logMe then
    deb.log(
      "[lib.colour.getColourName] " ..
      "no conditional colour for this parameter, using default colour "
    )
  end
  return defaultColour
end
