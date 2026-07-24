local state = require("src.lib.state._")
local items = require("src.config.items")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")
local makeParamNameDisplayEvent = require("src.lib.midi.makeParamNameDisplayEvent")
local debug = require("src.lib.debug._")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, 24 do
    local path, enabled, changed
    local item = items["encoder" .. i]

    path = "encoder" .. i .. ".enabled"
    if state.hasChanged(path) then
      enabled = state.update(path)
      changed = true
      --debug.log("DM: " .. path .. " is now " .. (enabled and "true" or "false"))
      if not enabled then
        -- turn of encoder's LED
        table.insert(events, makeSysexEvent("01 53 xx 00 00 00", { x = item.controller }))
      end
    else
      enabled = state.get(path)
    end

    if enabled then
      path = "encoder" .. i .. ".value"
      if changed or state.hasChanged(path) then
        local value = state.update(path)
        --debug.log("DM: " .. path .. " is now " .. tostring(value))
        table.insert(events, remote.make_midi(item.midi, { x = value }))
        local paramNameDisplayEvent = makeParamNameDisplayEvent(remote.get_item_name(item.index), item.controller)
        debug.log("item.controller: " .. item.controller)
        debug.log(debug.midiEventToString(paramNameDisplayEvent))
        table.insert(events, paramNameDisplayEvent)
      end
      path = "encoder" .. i .. ".colour"
      if changed or state.hasChanged(path) then
        local colour = state.update(path)
        table.insert(events, makeSysexEvent("01 53 xx " .. colour, { x = item.controller }))
      end
    end
  end
  return events
end
