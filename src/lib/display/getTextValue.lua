local state = require("src.lib.state._")
local getConditionalLabel = require("src.lib.display.getConditionalLabel")
local getLabel = require("src.lib.display.getLabel")
local getInterpolatedValue = require("src.lib.display.getInterpolatedValue")

return function(item)
  local textValue = item.text_value;
  local numValue = item.value;
  local param = item.remote_item_name;
  local deviceType = state.get("deviceType")
  local newTextValue, newParam = getConditionalLabel(deviceType, param, numValue)
  if not newTextValue then
    newTextValue =
        getLabel(deviceType, newParam or param, item)
        or getInterpolatedValue(deviceType, newParam or param, numValue)
        or textValue
  end
  return newTextValue
end
