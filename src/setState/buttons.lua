local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local buttonStates = require("src.lib.state.buttons")
local paramValues = require("src.lib.state.paramValues")
local cycleParams = require("src.config.cycleParams")
local conditionalValueLabels = require("src.config.conditionalValueLabels")
local col = require("src.lib.colour._")
local deb = require("src.lib.debug._")

-- parameters whose settings drive the display of other parameters (see
-- config/conditionalValueLabels), collected across all device types
local watchedParams = {}
for _, deviceConditionals in pairs(conditionalValueLabels) do
  for _, conditional in pairs(deviceConditionals) do
    watchedParams[conditional.dependsOn] = true
  end
end

-- handles changes of the buttons of the host (Reason)
return function(changedItems)
  local hasChanged
  for _, changedItemIndex in ipairs(changedItems) do
    local changedItem = remote.get_item_state(changedItemIndex)
    for i = 1, const.counts.buttons do
      local button = "button" .. i
      if changedItemIndex == items[button].index then
        hasChanged = true
        if changedItem.is_enabled then
          state.set(button .. ".enabled", true)
          if watchedParams[changedItem.remote_item_name] then
            local hostValue = changedItem.value
            paramValues[changedItem.remote_item_name] = hostValue
            -- debug.log("[setState.buttons] storing value " .. hostValue ..
            --   " for watched param " ..
            --   changedItem.remote_item_name)
          end
          local deviceType = state.getNext("deviceType")
          local colourName = col.getColourName(deviceType, changedItem.remote_item_name, items[button].colour)
          local deviceCycleParams = cycleParams[deviceType]
          if deviceCycleParams and deviceCycleParams[changedItem.remote_item_name] then
            -- a cycle button stays dim whatever the parameter's value; it is
            -- only bright while held down, which processMidi takes care of
            if not buttonStates.held[button] then
              state.set(button .. ".colour", col.getColour(colourName, 1))
            end
          else
            local hostValue = changedItem.value > 0 and true or false
            state.set(button .. ".value", hostValue)
            local colourValue = changedItem.value > 0 and 95 or 1
            state.set(button .. ".colour", col.getColour(colourName, colourValue))
          end
        else
          state.set(button .. ".enabled", false)
        end
      end
    end
  end
  if hasChanged then
    deb.log("[setState.buttons] RSN => CODEC")
  end
end
