local const = require "src.lcxl3.config.constants"
local state = require "src.lib.state._"
local cycleParams = require "src.config.cycleParams"
local momentaryParams = require "src.config.momentaryParams"

-- The way a button behaves for the parameter it is mapped to: an ordinary
-- toggle (values on/off), a cycle button that steps through the parameter's
-- values with every press (see config/cycleParams), or a momentary button that
-- the host flips itself on every press (see config/momentaryParams).
return function(param)
  local deviceType = state.get "deviceType"
  local deviceCycleParams = cycleParams[deviceType]
  if deviceCycleParams and deviceCycleParams[param] then
    return const.button.cycle
  end
  local deviceMomentaryParams = momentaryParams[deviceType]
  if deviceMomentaryParams and deviceMomentaryParams[param] then
    return const.button.momentary
  end
  return const.button.toggle
end
