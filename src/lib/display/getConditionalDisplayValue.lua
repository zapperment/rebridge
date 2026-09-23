local condi = require "src.lcxl3.lib.conditional._"
local state = require "src.lib.state._"
local str = require "src.lib.string._"
local deb = require "src.lib.debug._"

-- The label a single conditional gives for the current value of the parameter it
-- depends on, together with the name the parameter goes by while that parameter
-- has that value. Both are nil when the conditional says nothing about them.
local function getLabelAndVariation(conditional, hostValue)
  -- conditionals that replace the parameter with another one rather than
  -- relabelling it are handled by shouldDisplay
  if conditional.useOtherParamWhenValue then
    return nil, nil
  end
  local dependsOnValue = state.getHostValue(conditional.dependsOn)
  if dependsOnValue == nil then
    return nil, nil
  end
  -- two-valued parameters are stored as booleans
  -- (see src/remote/setState/buttons.lua)
  if type(dependsOnValue) == "boolean" then
    dependsOnValue = dependsOnValue and 127 or 0
  end
  local label, paramNameVariant
  if conditional.labels and dependsOnValue > 0 then
    local bucket = math.floor(hostValue * #conditional.labels / 128) + 1
    label = conditional.labels[bucket]
  end
  if conditional.variations then
    paramNameVariant = conditional.variations[tostring(dependsOnValue)]
  end
  return label, paramNameVariant
end

-- The label for a parameter whose display depends on the setting of another
-- parameter, e.g. SubTractor's LFO1 Rate showing note-length divisions while
-- LFO sync is enabled. Returns nil when nothing is configured for the
-- parameter or the parameter it depends on is off, leaving the caller to fall
-- back to the ordinary labels. A parameter can have more than one conditional,
-- in which case the first one that has something to say wins.
return function(deviceType, param, hostValue)
  local logMe = false --param == "Matrix Mod1 Source"
  if logMe then
    deb.log(
      "[lib:display:getConditionalDisplayValue] " ..
      "**param=" .. str.serialise(param) .. "**"
    )
  end
  for _, conditional in ipairs(condi.getConditionals(deviceType, param)) do
    local label, paramNameVariant = getLabelAndVariation(conditional, hostValue)
    if label or paramNameVariant then
      if logMe then
        deb.log(
          "[lib:display:getConditionalDisplayValue] " ..
          "dependsOn=" .. str.serialise(conditional.dependsOn) .. "; " ..
          "label=" .. str.serialise(label) .. "; " ..
          "paramNameVariant=" .. str.serialise(paramNameVariant)
        )
      end
      return label, paramNameVariant
    end
  end
  return nil, nil
end
