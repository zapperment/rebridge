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
        remote.make_midi("f0 00 20 29 02 15 01 53 xx " .. GetColourForValue(Colours[item.colour], value) .. " f7",
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

-- Computes a 7-bit RGB sysex colour string for a Launch Control style
-- controller, given a base colour and a 0-127 value.
--
-- value = 0    -> B at 5% of the original brightness
-- value = 95   -> original colour, unchanged
-- value = 1-94 -> B interpolated between the 0 and 95 cases
-- value = 127  -> S at 70% of the original saturation (B unchanged)
-- value = 96-126 -> S interpolated between the 95 and 127 cases

function GetColourForValue(hex, value)
  local function hexToRgb(hex)
    local num = tonumber(hex, 16)
    local r = math.floor(num / 65536) % 256
    local g = math.floor(num / 256) % 256
    local b = num % 256
    return r, g, b
  end

  local function rgbToHsb(r, g, b)
    r = r / 255
    g = g / 255
    b = b / 255
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min

    local h = 0
    if delta ~= 0 then
      if max == r then
        h = 60 * (((g - b) / delta) % 6)
      elseif max == g then
        h = 60 * ((b - r) / delta + 2)
      else
        h = 60 * ((r - g) / delta + 4)
      end
    end
    if h < 0 then h = h + 360 end

    local s = 0
    if max ~= 0 then s = delta / max end

    return h, s, max
  end

  local function hsbToRgb(h, s, b)
    local c = b * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = b - c

    local r1, g1, b1
    if h < 60 then
      r1, g1, b1 = c, x, 0
    elseif h < 120 then
      r1, g1, b1 = x, c, 0
    elseif h < 180 then
      r1, g1, b1 = 0, c, x
    elseif h < 240 then
      r1, g1, b1 = 0, x, c
    elseif h < 300 then
      r1, g1, b1 = x, 0, c
    else
      r1, g1, b1 = c, 0, x
    end

    return
        math.floor((r1 + m) * 255 + 0.5),
        math.floor((g1 + m) * 255 + 0.5),
        math.floor((b1 + m) * 255 + 0.5)
  end

  local function to7Bit(v)
    return math.floor((v * 127 / 255) + 0.5)
  end

  local r, g, b = hexToRgb(hex)
  local h, s, brightness = rgbToHsb(r, g, b)

  local newS, newB = s, brightness

  if value <= 95 then
    local t = value / 95
    newB = brightness * (0.05 + 0.95 * t)
  else
    local t = (value - 95) / 32
    newS = s * (1 - 0.3 * t)
  end

  local nr, ng, nb = hsbToRgb(h, newS, newB)
  return string.format("%02x %02x %02x", to7Bit(nr), to7Bit(ng), to7Bit(nb))
end
