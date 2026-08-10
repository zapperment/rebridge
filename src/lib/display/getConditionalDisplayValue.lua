local conditionals = require("src.config.conditionals")
local state = require("src.lib.state._")
local deb = require("src.lib.debug._")

-- The label for a parameter whose display depends on the setting of another
-- parameter, e.g. SubTractor's LFO1 Rate showing note-length divisions while
-- LFO sync is enabled. Returns nil when nothing is configured for the
-- parameter or the parameter it depends on is off, leaving the caller to fall
-- back to the ordinary labels.
return function(deviceType, param, hostValue)
  local logMe = false -- param == "LFO1 Rate"
  local conditionalParametersOfDevice = conditionals[deviceType]
  if not conditionalParametersOfDevice then
    return nil, nil
  end
  local conditionalOfParameter = conditionalParametersOfDevice[param]
  if not conditionalOfParameter then
    return nil, nil
  end
  local dependsOnValue = state.getHostValue(conditionalOfParameter.dependsOn)
  if dependsOnValue == nil then
    return nil, nil
  end
  if logMe then
    deb.log(
      "[lib:display:getConditionalDisplayValue] " ..
      "dependsOn=" .. conditionalOfParameter.dependsOn
    )
  end
  if logMe then
    deb.log(
      "[lib:display:getConditionalDisplayValue] " ..
      "dependsOnValue=" .. tostring(dependsOnValue)
    )
  end
  if type(dependsOnValue) == "boolean" then
    dependsOnValue = dependsOnValue and 1 or 0
  end
  if logMe then
    deb.log(
      "[lib:display:getConditionalDisplayValue] " ..
      "dependsOnValue=" .. tostring(dependsOnValue)
    )
  end
  local label, paramNameVariant
  if conditionalOfParameter.labels and dependsOnValue > 0 then
    local bucket = math.floor(hostValue * #conditionalOfParameter.labels / 128) + 1
    label = conditionalOfParameter.labels[bucket]
  end
  if conditionalOfParameter.variations then
    paramNameVariant = conditionalOfParameter.variations[tostring(dependsOnValue)]
  end
  return label, paramNameVariant
end
