local getConditionalDisplayValue = require("src.lib.display.getConditionalDisplayValue")
local getCustomDisplayValue = require("src.lib.display.getCustomDisplayValue")
local getInterpolatedDisplayValue = require("src.lib.display.getInterpolatedDisplayValue")
local state = require("src.lib.state._")
local deb = require("src.lib.debug._")

return function(control)
  local logMe = control == "encoder1"
  local hostTextValue = state.get(control .. ".hostTextValue")
  local hostValue = state.get(control .. ".hostValue")
  local param = state.get(control .. ".param")
  local deviceType = state.get("deviceType")
  local displayValue, newParam = getConditionalDisplayValue(deviceType, param, hostValue)
  if logMe and displayValue then
    deb.log(
      "[lib:display:getDisplayValue] " ..
      control .. " param " .. param ..
      " - got display value! returning **" .. displayValue .. "**"
    )
  end
  if not displayValue then
    local customDisplayValue = getCustomDisplayValue(deviceType, newParam or param, hostValue, hostTextValue)
    if logMe and displayValue then
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
    displayValue =
        customDisplayValue
        or interpolatedDisplayValue
        or hostTextValue
  end
  return displayValue
end
