local ctrl = require "src.config.controls"
local state = require "src.lib.state._"
local items = require "src.config.items"
local str = require "src.lib.string._"
local deb = require "src.lib.debug._"

return function(event)
  for _, control in ipairs(ctrl.rackUIs) do
    local logMe = false --control == "rackUI1"
    local enabled, enabledChanged = state.update(control .. ".enabled")
    local param, paramChanged = state.update(control .. ".param")
    local hostValue, hostValueChanged = state.update(control .. ".hostValue")
    if logMe and not enabled then
      deb.log(
        "[remote:processMidi:rackUI] " ..
        "not enabled: " .. control
      )
    end
    if logMe and not hostValueChanged then
      deb.log(
        "[remote:processMidi:rackUI] " ..
        "unchanged: " .. control .. "=" .. str.serialise(hostValue)
      )
    end
    state.update(control .. ".hostTextValue")
    if enabled and not enabledChanged and hostValueChanged then
      local item = items[control]
      if logMe then
        deb.log(
          "[remote:processMidi:rackUI] " ..
          "handling input: **" .. str.serialise(hostValue) .. "** " ..
          "(" .. type(hostValue) .. ")"
        )
        deb.log(
          "[remote:processMidi:rackUI] " ..
          "item: " .. str.serialise(item.index)
        )
      end
      remote.handle_input({
        time_stamp = event.time_stamp,
        item = item.index,
        value = hostValue
      })
    end
  end
  return false -- "processed" is always false for rack UI updates
end
