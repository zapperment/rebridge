local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local paramValues = require("src.lib.state.paramValues")
local cycleParams = require("src.config.cycleParams")
local conditionalValueLabels = require("src.config.conditionalValueLabels")
local disp = require("src.lib.display._")
local deb = require("src.lib.debug._")

-- the host (Reason) reports an on/off button as "0" or "1", which reads poorly
-- on the display
local defaultValueLabels = {
  ["0"] = "Off",
  ["1"] = "On",
}
-- parameters whose settings drive the display of other parameters (see
-- config/conditionalValueLabels), collected across all device types
local watchedParams = {}
for _, deviceConditionals in pairs(conditionalValueLabels) do
  for _, conditional in pairs(deviceConditionals) do
    watchedParams[conditional.dependsOn] = true
  end
end

-- turns the value the host reports into what the display should show, honouring
-- the labels a device defines for buttons that are not simply on/off; a value
-- with no label is shown as the host provides it
local function getValueLabel(paramName, itemState)
  local deviceType = state.get("deviceType")
  local label = disp.getLabel(deviceType, paramName, itemState)
  if label then
    return label
  end
  local textValue = itemState.text_value
  local deviceCycleParams = cycleParams[deviceType]
  if deviceCycleParams and deviceCycleParams[paramName] then
    -- a cycling parameter's values are not on/off, so without labels of its
    -- own it shows the plain value rather than the On/Off defaults
    return textValue
  end
  return defaultValueLabels[textValue] or textValue
end

-- handles changes of the buttons of the host (Reason)
return function(changedItems)
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, const.counts.buttons do
      local control = "button" .. i
      if changedItemIndex == items[control].index then
        if changedItem.is_enabled then
          state.set(control .. ".enabled", true)
          local param = changedItem.remote_item_name
          state.set(control .. ".param", param)
          local hostValue = changedItem.value
          if watchedParams[param] then
            -- if param == "Mode1" then
            --   deb.log("[remote.setState.buttons] setting Mode1 watched param to " .. hostValue)
            -- end
            paramValues[param] = hostValue
          end
          -- if param == "Mode1" then
          --   deb.log("[remote:setState:buttons] mode1 hostValue=" .. hostValue)
          -- end
          local deviceType = state.getNext("deviceType")
          local deviceCycleParams = cycleParams[deviceType]
          if deviceCycleParams and deviceCycleParams[param] then
            state.set(control .. ".type", const.button.cycle)
            state.set(control .. ".hostValue", hostValue)
          else
            state.set(control .. ".type", const.button.toggle)
            state.set(control .. ".hostValue", hostValue > 0 and true or false)
          end
          state.set(control .. ".hostTextValue", getValueLabel(param, changedItem))
        else
          state.set(control .. ".enabled", false)
        end
      end
    end
  end
end
