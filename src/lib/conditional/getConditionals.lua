local cond = require "src.config.conditionals"

-- The conditionals config/conditionals holds for a parameter, always as a list.
--
-- A parameter that depends on a single other parameter is written as one table,
-- a parameter that depends on several as a list of such tables (see the comment
-- at the top of config/conditionals). Both come back from here as a list, so
-- that callers only ever have to deal with the one shape. Returns an empty list
-- when the device type or the parameter has nothing configured.
return function(deviceType, param)
  if not deviceType or not param then
    return {}
  end
  local conditionalsForDevice = cond[deviceType]
  if not conditionalsForDevice then
    return {}
  end
  local conditional = conditionalsForDevice[param]
  if not conditional then
    return {}
  end
  -- a single conditional names the parameter it depends on itself, a list of
  -- conditionals leaves that to its entries
  if conditional.dependsOn then
    return { conditional }
  end
  return conditional
end
