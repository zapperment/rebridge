local items = require "src.config.items"
local const = require "src.config.constants"
local state = require "src.lib.state._"

-- the option each option selector stands for: 0 for the one bound to the
-- mapping in force while no option is selected
local optionsByIndex
local function getOption(hostItemIndex)
  if not optionsByIndex then
    optionsByIndex = { [items.noOptionSelect.index] = 0 }
    for option = 1, const.counts.options do
      optionsByIndex[items["optionSelect" .. option].index] = option
    end
  end
  return optionsByIndex[hostItemIndex]
end

-- Handles changes of the selector and the option selectors reported by the
-- host (Reason). The selector is enabled while the target device is a
-- selecting device, and carries the value of its selector parameter; an option
-- selector is enabled while the device's remote map binds it to a group value,
-- and carries a value above zero while that value's mapping is in force. From
-- that the codec learns which option is selected and whether the mapping in
-- force belongs to it, wherever the change came from: the selection buttons,
-- the device's own panel, or the host switching devices.
return function(hostItems)
  local hasChanged = false
  for _, hostItemIndex in ipairs(hostItems) do
    if hostItemIndex == items.selector.index then
      hasChanged = true
      state.setSelectorState(remote.get_item_state(hostItemIndex))
    else
      local option = getOption(hostItemIndex)
      if option then
        hasChanged = true
        state.setOptionState(option, remote.get_item_state(hostItemIndex))
      end
    end
  end

  if hasChanged then
    state.updateSelection()
  end
end
