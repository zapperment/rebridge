local state = require("src.lib.state._")
local cycleParams = require("src.config.cycleParams")

-- determine if a button is a toggle (values on/off),
-- or if it cycles through values with every button push
return function(param)
  local deviceType = state.get("deviceType")
  local deviceCycleParams = cycleParams[deviceType]
  return not deviceCycleParams or not deviceCycleParams[param]
end
