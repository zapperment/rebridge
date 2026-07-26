local conditionalValueLabels = require("src.config.conditionalValueLabels")
local paramValues = require("src.lib.state.paramValues")

-- The label for a parameter whose display depends on the setting of another
-- parameter, e.g. SubTractor's LFO1 Rate showing note-length divisions while
-- LFO sync is enabled. Returns nil when nothing is configured for the
-- parameter or the parameter it depends on is off, leaving the caller to fall
-- back to the ordinary labels.
return function(deviceType, paramName, value)
  local deviceConditionals = conditionalValueLabels[deviceType]
  local conditional = deviceConditionals and deviceConditionals[paramName]
  if not conditional or not paramValues[conditional.dependsOn] then
    return nil
  end
  local bucket = math.floor(value * #conditional.labels / 128) + 1
  return conditional.labels[bucket]
end
