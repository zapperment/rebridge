local const = require "src.lcxl3.config.constants"
local items = require "src.lcxl3.config.items"
local setSelection = require "src.remote.setState.selection"

-- Simulates the host (Reason) reporting the selection of the target device
-- through the selector and the option selectors.
--
-- selectorValue is the value of the selector parameter (-1 for no option
-- selected), or nil for a device that is not a selecting device; optionCount is
-- the number of options the device's remote map defines a group value for; and
-- activeOption is the option whose group is in force (0 for the one of no option
-- selected), or nil if the host reports none.
return function(selectorValue, optionCount, activeOption)
  local states = {}
  local changedItems = {}
  local function report(item, itemState)
    states[item.index] = itemState
    table.insert(changedItems, item.index)
  end
  report(items.selector, {
    is_enabled = selectorValue ~= nil,
    value = selectorValue or 0,
    remote_item_name = selectorValue ~= nil and "Pattern Select" or "",
  })
  report(items.noOptionSelect, { is_enabled = optionCount > 0, value = activeOption == 0 and 1 or 0 })
  for option = 1, const.counts.options do
    report(items["optionSelect" .. option], {
      is_enabled = option <= optionCount,
      value = activeOption == option and 1 or 0,
    })
  end
  remote.mock "get_item_state":impl(function(index)
    return states[index]
  end)
  setSelection(changedItems)
end
