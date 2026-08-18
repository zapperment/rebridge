local getConditionalDisplayValue = require "src.lib.display.getConditionalDisplayValue"
local getCustomDisplayValue = require "src.lib.display.getCustomDisplayValue"
local getInterpolatedDisplayValue = require "src.lib.display.getInterpolatedDisplayValue"
local state = require "src.lib.state._"
local deb = require "src.lib.debug._"

return function(control)
  local logMe = control == "encoder2" or control == "encoder2alt"
  local hostTextValue = state.get(control .. ".hostTextValue")
  local hostValue = state.get(control .. ".hostValue")
  local param = state.get(control .. ".param")
  local deviceType = state.get "deviceType"
  local shouldDisplayValue, newParam = getConditionalDisplayValue(deviceType, param, hostValue)
  if logMe and shouldDisplayValue then
    deb.log(
      "[lib:display:getDisplayValue] " ..
      control .. " param " .. param ..
      " - got display value! returning **" .. shouldDisplayValue .. "**"
    )
  end
  if not shouldDisplayValue then
    local customDisplayValue = getCustomDisplayValue(deviceType, newParam or param, hostValue, hostTextValue)
    if logMe and shouldDisplayValue then
      deb.log(
        "[lib:display:getDisplayValue] " ..
        control .. " param " .. param ..
        " - got custom display value! returning **" .. customDisplayValue .. "**"
      )
    end
    local interpolatedDisplayValue = getInterpolatedDisplayValue(deviceType, newParam or param, hostValue)
    if logMe and interpolatedDisplayValue then
      deb.log(
        "[lib:display:getDisplayValue] " ..
        control .. " param " .. param ..
        " - got interpolated display value! returning **" .. interpolatedDisplayValue .. "**"
      )
    end
    if logMe and not customDisplayValue and not interpolatedDisplayValue then
      deb.log(
        "[lib:display:getDisplayValue] " ..
        control .. " param " .. param ..
        " - no custom or interpolated display value! returning **" .. hostTextValue .. "**"
      )
    end
    shouldDisplayValue =
        customDisplayValue
        or interpolatedDisplayValue
        or hostTextValue
  end
  return shouldDisplayValue
end
