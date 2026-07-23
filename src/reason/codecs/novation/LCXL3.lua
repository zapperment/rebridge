local getColourForValue = require("src.utils.colour.getColourForValue")

Items = {
  encoder1 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 0d xx", controller = 13, colour = "fhyd" },
  encoder2 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 0e xx", controller = 14, colour = "tang" },
  encoder3 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 0f xx", controller = 15, colour = "suns" },
  encoder4 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 10 xx", controller = 16, colour = "fore" },
  encoder5 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 11 xx", controller = 17, colour = "aqua" },
  encoder6 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 12 xx", controller = 18, colour = "coco" },
  encoder7 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 13 xx", controller = 19, colour = "plum" },
  encoder8 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 14 xx", controller = 20, colour = "flam" },
  encoder9 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 15 xx", controller = 21, colour = "fhyd" },
  encoder10 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 16 xx", controller = 22, colour = "tang" },
  encoder11 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 17 xx", controller = 23, colour = "suns" },
  encoder12 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 18 xx", controller = 24, colour = "fore" },
  encoder13 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 19 xx", controller = 25, colour = "aqua" },
  encoder14 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1a xx", controller = 26, colour = "coco" },
  encoder15 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1b xx", controller = 27, colour = "plum" },
  encoder16 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1c xx", controller = 28, colour = "flam" },
  encoder17 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1d xx", controller = 29, colour = "fhyd" },
  encoder18 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1e xx", controller = 30, colour = "tang" },
  encoder19 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 1f xx", controller = 31, colour = "suns" },
  encoder20 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 20 xx", controller = 32, colour = "fore" },
  encoder21 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 21 xx", controller = 33, colour = "aqua" },
  encoder22 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 22 xx", controller = 34, colour = "coco" },
  encoder23 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 23 xx", controller = 35, colour = "plum" },
  encoder24 = { input = "value", output = "value", min = 0, max = 127, midi = "bf 24 xx", controller = 36, colour = "flam" }
}

Colours = {
  fhyd = "fe3636",
  tang = "f66c02",
  duri = "dbc302",
  poml = "85961f",
  tiff = "14bfaf",
  coco = "1a2f96",
  plum = "624bad",
  flam = "fd39d4",
  ceru = "0ea4ee",
  suns = "fff034",
  aqua = "0f9c8e",
  fore = "3dc300"
}

function remote_init()
  local itemsToDefine = {}
  for name, item in pairs(Items) do
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
  for _, item in pairs(Items) do
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
  for _, item in pairs(Items) do
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
  for _, item in pairs(Items) do
    if item.updateValue then
      local value = remote.get_item_value(item.index)
      table.insert(events, remote.make_midi(item.midi, { x = value }))
      item.updateValue = false
    end
    if item.updateColour then
      local value = remote.get_item_value(item.index)
      table.insert(events,
        remote.make_midi(
          "f0 00 20 29 02 15 01 53 xx " .. getColourForValue(Colours[item.colour], value) .. " f7",
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
