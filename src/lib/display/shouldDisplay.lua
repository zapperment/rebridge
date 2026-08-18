local tbl = require "src.lib.table._"
local cond = require "src.config.conditionals"
local state = require "src.lib.state._"
local str = require "src.lib.string._"
local deb = require "src.lib.debug._"

return function(deviceType, param)
  local logMe = param == "Delay Time" or param == "Delay Synced Time"
  if logMe then
    deb.log(
      "[lib:display:getConditionalDisplayValue] " ..
      "**param=" .. str.serialise(param) .. "**"
    )
  end
  local shouldDisplay = true
  local conditional = tbl.getValueFromPath(
    cond,
    deviceType .. "." .. param
  )
  if not conditional or not conditional.useOtherParamWhenValue then
    if logMe then
      if not conditional then
        deb.log(
          "[lib:display:shouldDisplay] " ..
          "no conditional found for param " .. str.serialise(param) .. "; " ..
          "returning true (should display)"
        )
      else
        deb.log(
          "[lib:display:shouldDisplay] " ..
          "conditional found for param " .. str.serialise(param) .. " " ..
          "but no “useOtherParamWhenValue” " ..
          "returning true (should display)"
        )
      end
    end
    return shouldDisplay
  end
  local dependsOnValue = state.getHostValue(conditional.dependsOn)
  if dependsOnValue == nil then
    if logMe then
      deb.log(
        "[lib:display:shouldDisplay] " ..
        "param " .. str.serialise(param) .. " " ..
        "depends on " .. str.serialise(conditional.dependsOn) .. ", " ..
        "but there is no value stored for that; " ..
        "returning true (should display)"
      )
    end
    return shouldDisplay
  end
  shouldDisplay = conditional.useOtherParamWhenValue ~= dependsOnValue
  if logMe then
    deb.log(
      "[lib:display:shouldDisplay] " ..
      "param " .. str.serialise(param) .. " " ..
      "depends on " .. str.serialise(conditional.dependsOn) .. " " ..
      "(currently " .. str.serialise(dependsOnValue) .. "); " ..
      "should not display when depends on value is " ..
      str.serialise(conditional.useOtherParamWhenValue) .. "; " ..
      "returning " .. str.serialise(shouldDisplay) .. " " ..
      "(should " .. (shouldDisplay and "" or "not ") .. "display)"
    )
  end
  return shouldDisplay
end
