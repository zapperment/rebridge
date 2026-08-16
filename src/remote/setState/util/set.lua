local items = require("src.config.items")
local state = require("src.lib.state._")

return function(hostItemIndex, control, enabledCallback, disabledCallback)
  if hostItemIndex ~= items[control].index then
    return
  end
  local hostItem = remote.get_item_state(hostItemIndex)
  local isEnabled = hostItem.is_enabled
  state.set(control .. ".enabled", isEnabled)
  local param = hostItem.remote_item_name
  state.set(control .. ".param", param)
  if isEnabled then
    local hostTextValue = hostItem.text_value
    state.set(control .. ".hostTextValue", hostTextValue)
    local hostValue = hostItem.value;
    state.set(control .. ".hostValue", hostValue)
    if enabledCallback then
      enabledCallback(param, hostValue)
    end
    return
  end
  if disabledCallback then
    disabledCallback()
  end
end
