local state = require "src.lib.state._"
local cycleParams = require "src.config.cycleParams"
local str = require "src.lib.string._"
local deb = require "src.lib.debug._"

-- determine if a button is a toggle (values on/off),
-- or if it cycles through values with every button push
return function(param)
  local logMe = false --param == "Enabled"
  local deviceType = state.get "deviceType"
  local deviceCycleParams = cycleParams[deviceType]
  if logMe then
    deb.log(
      "[remote:setState:util:isToggle] " ..
      "device cycle params for param " .. str.serialise(param) .. " " ..
      "of device " .. str.serialise(deviceType) .. ": " ..
      str.serialise(deviceCycleParams)
    )
  end
  return not deviceCycleParams or not deviceCycleParams[param]
end
