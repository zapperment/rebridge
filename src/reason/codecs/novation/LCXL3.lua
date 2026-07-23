local getColour = require("src.utils.colour.getColour")
local items = require("src.config.items")

function remote_init()
  local itemsToDefine = {}
  for name, item in pairs(items) do
    table.insert(itemsToDefine, {
      name = name,
      input = item.input,
      output = item.output,
      min = item.min,
      max = item.max,
    })
    item.index = #itemsToDefine
    item.lastInputTime = 0
    item.updateValue = false
    item.updateColour = false
  end
  remote.define_items(itemsToDefine)
end

-- Launch Control -> Remote
function remote_process_midi(event)
  local processed = false
  for _, item in pairs(items) do
    if item.controller ~= nil then
      local match = remote.match_midi(item.midi, event)
      if match ~= nil then
        item.lastInputTime = remote.get_time_ms()
        -- Remote -> Reason
        remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = match.x })
        processed = true
      end
    end
  end
  return processed
end

-- Reason -> Remote
function remote_set_state(changed_items)
  local now = remote.get_time_ms()
  for _, item in pairs(items) do
    for _, changedItemIndex in ipairs(changed_items) do
      if item.index == changedItemIndex then
        item.updateColour = true
        if now - item.lastInputTime > 100 then
          item.updateValue = true
        end
      end
    end
  end
end

-- Remote -> Launch Control
function remote_deliver_midi()
  local events = {}
  for _, item in pairs(items) do
    if item.updateValue then
      local value = remote.get_item_value(item.index)
      table.insert(events, remote.make_midi(item.midi, { x = value }))
      item.updateValue = false
    end
    if item.updateColour then
      local value = remote.get_item_value(item.index)
      table.insert(events,
        remote.make_midi(
          "f0 00 20 29 02 15 01 53 xx " .. getColour(item.colour, value) .. " f7",
          { x = item.controller }))
      item.updateColour = false
    end
  end
  return events
end

function remote_prepare_for_use()
  return {
    -- turn on DAW mode
    remote.make_midi("f0 00 20 29 02 15 02 7f f7"),
    remote.make_midi("b6 45 00"),
    remote.make_midi("b6 48 00"),
    remote.make_midi("b6 49 00"),
  }
end

function remote_release_from_use()
  return {
    -- turn off DAW mode
    remote.make_midi("F0 00 20 29 02 15 02 00 F7"),
  }
end
