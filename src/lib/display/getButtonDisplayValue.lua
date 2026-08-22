local const = require "src.config.constants"
local getCustomDisplayValue = require "src.lib.display.getCustomDisplayValue"
local state = require "src.lib.state._"
local deb = require "src.lib.debug._"

local defaultDisplayValues = {
  ["0"] = "Off",
  ["1"] = "On",
}

return function(control)
  local logMe = false --control == "button6"
  local hostTextValue = state.get(control .. ".hostTextValue")
  local hostValue = state.get(control .. ".hostValue")
  local param = state.get(control .. ".param")
  local type = state.get(control .. ".type")
  local deviceType = state.get "deviceType"
  if logMe then
    deb.log(
      "[lib:display:getButtonDisplayValue] " ..
      "deviceType=" .. deviceType .. "; " ..
      "type=" .. type .. "; " ..
      "param=" .. param .. "; " ..
      "hostTextValue=" .. hostTextValue .. "; " ..
      "hostValue=" .. tostring(hostValue)
    )
  end
  local customDisplayValue = getCustomDisplayValue(deviceType, param, hostValue, hostTextValue)
  if customDisplayValue then
    if logMe then
      deb.log(
        "[lib:display:getButtonDisplayValue] " ..
        control .. " param " .. param ..
        " got custom display value! returning **" .. customDisplayValue .. "**"
      )
    end
    return customDisplayValue
  end
  if type == const.button.cycle then
    if logMe then
      deb.log(
        "[lib:display:getButtonDisplayValue] " ..
        control .. " param " .. param ..
        " - it's a cycle button! returning **" .. hostTextValue .. "**"
      )
    end
    return hostTextValue
  end
  local defaultDisplayValue = defaultDisplayValues[hostTextValue]
  if logMe and defaultDisplayValue then
    deb.log(
      "[lib:display:getButtonDisplayValue] " ..
      control .. " param " .. param ..
      " - got default display value! returning **" .. defaultDisplayValue .. "**"
    )
  end
  if logMe and not defaultDisplayValue then
    deb.log(
      "[lib:display:getButtonDisplayValue] " ..
      control .. " param " .. param ..
      " - no default display value, returning **" .. hostTextValue .. "**"
    )
  end
  return defaultDisplayValue or hostTextValue
end
