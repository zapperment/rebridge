local stateUtils = require("src.lib.state.utils")
local items = require("src.config.items")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, 24 do
    local path, enabled, changed
    local item = items["encoder" .. i]

    path = "encoder" .. i .. ".enabled"
    if stateUtils.hasChanged(path) then
      stateUtils.update(path)
      enabled = stateUtils.get(path)
      changed = true
      if not enabled then
        -- turn of encoder's LED
        table.insert(events, remote.make_midi("f0 00 20 29 02 15 01 53 xx 00 00 00 f7", { x = item.controller }))
      end
    else
      enabled = stateUtils.get(path)
    end

    if enabled then
      path = "encoder" .. i .. ".value"
      if changed or stateUtils.hasChanged(path) then
        stateUtils.update(path)
        local value = stateUtils.get(path)
        table.insert(events, remote.make_midi(item.midi, { x = value }))
      end
      path = "encoder" .. i .. ".colour"
      if changed or stateUtils.hasChanged(path) then
        stateUtils.update(path)
        local colour = stateUtils.get(path)
        table.insert(events, remote.make_midi("f0 00 20 29 02 15 01 53 xx " .. colour .. " f7", { x = item.controller }))
      end
    end
  end
  return events
end
