local items = require "src.config.items"
local state = require "src.lib.state._"
local str = require "src.lib.string._"
local deb = require "src.lib.debug._"

return function(hostItemIndex, control, enabledCallback, disabledCallback)
  local logMe = control == "rackUI1"
  if hostItemIndex ~= items[control].index then
    return
  end
  if logMe then
    deb.log(
      "[remote:setState:set] " ..
      "**control=" .. str.serialise(control) .. "**"
    )
  end
  local hostItem = remote.get_item_state(hostItemIndex)
  local isEnabled = hostItem.is_enabled
  if logMe then
    deb.log(
      "[remote:setState:set] " ..
      "isEnabled=" .. str.serialise(isEnabled)
    )
  end
  state.set(control .. ".enabled", isEnabled)
  local param = hostItem.remote_item_name
  if logMe then
    deb.log(
      "[remote:setState:set] " ..
      "param=" .. str.serialise(param)
    )
  end
  state.set(control .. ".param", param)
  if isEnabled then
    local hostTextValue = hostItem.text_value
    if logMe then
      deb.log(
        "[remote:setState:set] " ..
        "hostTextValue=" .. str.serialise(hostTextValue)
      )
    end
    state.set(control .. ".hostTextValue", hostTextValue)
    local hostValue = hostItem.value;
    if logMe then
      deb.log(
        "[remote:setState:set] " ..
        "hostValue=" .. str.serialise(hostValue)
      )
    end
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
