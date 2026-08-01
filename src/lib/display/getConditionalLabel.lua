local conditionalValueLabels = require("src.config.conditionalValueLabels")
local paramValues = require("src.lib.state.paramValues")
local debug = require("src.lib.debug._")

-- The label for a parameter whose display depends on the setting of another
-- parameter, e.g. SubTractor's LFO1 Rate showing note-length divisions while
-- LFO sync is enabled. Returns nil when nothing is configured for the
-- parameter or the parameter it depends on is off, leaving the caller to fall
-- back to the ordinary labels.
return function(deviceType, paramName, value)
  local conditionalParametersOfDevice = conditionalValueLabels[deviceType]
  if not conditionalParametersOfDevice then
    debug.log("[lib.display.getConditionalLabel] device " .. deviceType .. " has no conditional value labels")
    return nil, nil
  end
  local conditionalOfParameter = conditionalParametersOfDevice[paramName]
  if not conditionalOfParameter then
    debug.log("[lib.display.getConditionalLabel] parameter " ..
      paramName .. " of device " .. deviceType .. " has no conditional value labels")
    return nil, nil
  end
  local dependsOnValue = paramValues[conditionalOfParameter.dependsOn]
  if dependsOnValue == nil then
    debug.log("[lib.display.getConditionalLabel] parameter " ..
      paramName ..
      " of device " ..
      deviceType .. " depends on parameter " .. conditionalOfParameter.dependsOn .. ", but that parameter has no value")
    return nil, nil
  end
  local label, paramNameVariant
  if conditionalOfParameter.labels and dependsOnValue > 0 then
    local bucket = math.floor(value * #conditionalOfParameter.labels / 128) + 1
    label = conditionalOfParameter.labels[bucket]
    debug.log("[lib.display.getConditionalLabel] parameter " ..
      paramName ..
      " of device " ..
      deviceType ..
      " depends on parameter " ..
      conditionalOfParameter.dependsOn .. ", which has value " .. dependsOnValue ..
      ", resulting in label " .. label)
  end
  if conditionalOfParameter.variations then
    paramNameVariant = conditionalOfParameter.variations[tostring(dependsOnValue)]
    if not paramNameVariant then
      debug.log("[lib.display.getConditionalLabel] parameter " ..
        paramName ..
        " of device " ..
        deviceType ..
        " depends on parameter " ..
        conditionalOfParameter.dependsOn ..
        ", which has value " .. dependsOnValue .. ", which has no parameter name variant ")
    else
      debug.log("[lib.display.getConditionalLabel] parameter " ..
        paramName ..
        " of device " ..
        deviceType ..
        " depends on parameter " ..
        conditionalOfParameter.dependsOn ..
        ", which has value " .. dependsOnValue .. ", resulting in parameter name variant " .. paramNameVariant)
    end
  end
  return label, paramNameVariant
end
