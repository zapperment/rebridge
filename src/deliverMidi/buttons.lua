local stateUtils = require("src.lib.state.utils")
local items = require("src.config.items")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  local message = ""
  for i = 1, 16 do
    local path, enabled
    local enabledChanged = false
    local item = items["button" .. i]

    path = "button" .. i .. ".enabled"
    if stateUtils.hasChanged(path) then
      stateUtils.update(path)
      enabled = stateUtils.get(path)
      enabledChanged = true
      if not enabled then
        -- turn of button's LED
        table.insert(events, remote.make_midi("f0 00 20 29 02 15 01 53 xx 00 00 00 f7", { x = item.controller }))
      end
    else
      enabled = stateUtils.get(path)
    end

    if enabled then
      path = "button" .. i .. ".value"
      if enabledChanged or stateUtils.hasChanged(path) then
        stateUtils.update(path)
        -- no MIDI command sent out for button change
      end
      path = "button" .. i .. ".colour"
      if enabledChanged or stateUtils.hasChanged(path) then
        local colour = stateUtils.update(path)
        table.insert(events, remote.make_midi("f0 00 20 29 02 15 01 53 xx " .. colour .. " f7", { x = item.controller }))
      end
    end
  end
  return events
end
