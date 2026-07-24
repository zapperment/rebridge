local state = require("src.lib.state._")
local items = require("src.config.items")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, 16 do
    local path, enabled
    local enabledChanged = false
    local item = items["button" .. i]

    path = "button" .. i .. ".enabled"
    if state.hasChanged(path) then
      state.update(path)
      enabled = state.get(path)
      enabledChanged = true
      if not enabled then
        -- turn of button's LED
        table.insert(events, makeSysexEvent("01 53 xx 00 00 00", { x = item.controller }))
      end
    else
      enabled = state.get(path)
    end

    if enabled then
      path = "button" .. i .. ".value"
      if enabledChanged or state.hasChanged(path) then
        state.update(path)
        -- no MIDI command sent out for button change
      end
      path = "button" .. i .. ".colour"
      if enabledChanged or state.hasChanged(path) then
        local colour = state.update(path)
        table.insert(events, makeSysexEvent("01 53 xx " .. colour, { x = item.controller }))
      end
    end
  end
  return events
end
