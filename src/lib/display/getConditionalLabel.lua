local conditionalValueLabels = require("src.config.conditionalValueLabels")
local paramValues = require("src.lib.state.paramValues")
local deb = require("src.lib.debug._")

-- The label for a parameter whose display depends on the setting of another
-- parameter, e.g. SubTractor's LFO1 Rate showing note-length divisions while
-- LFO sync is enabled. Returns nil when nothing is configured for the
-- parameter or the parameter it depends on is off, leaving the caller to fall
-- back to the ordinary labels.
return function(deviceType, paramName, value)
  local conditionalParametersOfDevice = conditionalValueLabels[deviceType]
  if not conditionalParametersOfDevice then
    return nil, nil
  end
  local conditionalOfParameter = conditionalParametersOfDevice[paramName]
  if not conditionalOfParameter then
    return nil, nil
  end
  local dependsOnValue = paramValues[conditionalOfParameter.dependsOn]
  if dependsOnValue == nil then
    return nil, nil
  end
  local label, paramNameVariant
  if conditionalOfParameter.labels and dependsOnValue > 0 then
    local bucket = math.floor(value * #conditionalOfParameter.labels / 128) + 1
    label = conditionalOfParameter.labels[bucket]
  end
  if conditionalOfParameter.variations then
    paramNameVariant = conditionalOfParameter.variations[tostring(dependsOnValue)]
  end
  return label, paramNameVariant
end
