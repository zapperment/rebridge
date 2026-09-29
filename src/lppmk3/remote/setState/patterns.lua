local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"
local ctrl = require "src.lppmk3.config.controls"
local deb = require "src.lib.debug._"
local str = require "src.lib.string._"
local timing = require "src.lppmk3.lib.timing._"

-- the name of the focused LaunchEon, or nil while none has remote focus
local function launchEonName()
  local index = items.deviceName.index
  if not remote.is_item_enabled(index) then
    return nil
  end
  return remote.get_item_text_value(index)
end

-- handles changes of the patterns of the host (Reason); the host reports a
-- pattern the moment it is selected, which only starts to play at once while
-- no switch can be pending, or when the device has just been made active or
-- another LaunchEon has been focused, as there is no way of knowing what
-- played before
return function(hostItems)
  local logMe = false
  local launchEon = launchEonName()
  local launchEonChanged = launchEon ~= state.get "launchEon"
  state.set("launchEon", launchEon)
  for _, hostItemIndex in ipairs(hostItems) do
    for _, device in ipairs(ctrl.devices) do
      if hostItemIndex == items[device].index then
        local hostItem = remote.get_item_state(hostItemIndex)
        local wasEnabled = state.get(device .. ".enabled")
        local isEnabled = hostItem.is_enabled
        state.set(device .. ".enabled", isEnabled)
        local hostValue = hostItem.value;
        if logMe then
          deb.log(
            "[lppmk3.setState.patterns] " ..
            "hostValue=" .. str.serialise(hostValue)
          )
        end
        state.set(device .. ".hostValue", hostValue)
        if not wasEnabled or not timing.canBePending() then
          state.set(device .. ".playingValue", hostValue)
        end
      end
    end
  end
  -- the patterns of another LaunchEon, including those the host does not
  -- report as they happen to equal the previous LaunchEon's, are all playing
  if launchEonChanged then
    for _, device in ipairs(ctrl.devices) do
      state.set(device .. ".playingValue", state.get(device .. ".hostValue"))
    end
  end
end
