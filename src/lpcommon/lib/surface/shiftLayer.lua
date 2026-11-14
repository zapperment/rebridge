local const = require "src.lpcommon.config.constants"
local col = require "src.lpcommon.lib.colour._"
local shift = require "src.lpcommon.lib.state._"

-- The Shift layer of a surface: the controls its pads and buttons stand for
-- while Shift is held, for surfaces that have fewer buttons than Launchnik.
--
-- A device says in controls.shiftLayer which of its pads and buttons, by
-- their number, are which control while Shift is held. That control is a
-- number no pad or button of the device has, so that the rest of the codec
-- can tell it from the one in the same place; false stands for a place that
-- is dark and does nothing while Shift is held. The rest of the codec only
-- knows controls: the Shift layer turns what is pressed into the control it
-- stands for, and lights into the events of the place that shows them.
--
-- A place shows the light of one control at a time, so the Shift layer
-- remembers the lights of the controls that share a place, and delivers those
-- of the other control whenever Shift is pressed or let go.

local flashing = const.colourBehaviour.flashing

local function new(device)
  local layer = device.controls.shiftLayer or {}
  local makeColourEvent = device.midi.makeColourEvent

  -- the places that are another control while Shift is held, in order, and
  -- the place of each of those controls
  local places = {}
  local placeOf = {}
  for place, control in pairs(layer) do
    table.insert(places, place)
    if control then
      placeOf[control] = place
    end
  end
  table.sort(places)

  -- the control each place held down was pressed as
  local held = {}
  -- the lights of the controls that share a place, by control
  local lights = {}
  -- whether the places show their controls of the Shift layer
  local shown = false

  local self = {}

  -- forgets everything, as when the codec is loaded
  function self.reset()
    held = {}
    lights = {}
    shown = false
  end

  -- the control a pad or button stands for right now
  local function controlAt(place)
    if shift.isShifted() and layer[place] ~= nil then
      return layer[place]
    end
    return place
  end

  -- the control that the pad or button with the number given stands for as
  -- it is pressed (a value above 0) or let go; false if it stands for none.
  -- One that is let go stands for what it was pressed as, even if Shift has
  -- been pressed or let go since, so that nothing stays held down.
  function self.translate(place, value)
    if value > 0 then
      held[place] = controlAt(place)
      return held[place]
    end
    local control = held[place]
    held[place] = nil
    if control == nil then
      return controlAt(place)
    end
    return control
  end

  -- a flashing light adds to the static one that precedes it; any other
  -- light replaces what the control showed
  local function remember(light)
    if light.behaviour == flashing and lights[light.control] then
      table.insert(lights[light.control], light)
    else
      lights[light.control] = { light }
    end
  end

  -- the MIDI events that make the surface show the lights given (see
  -- makeLight.lua): those of the controls in sight right away, the others
  -- once Shift brings them into sight
  function self.deliver(newLights)
    local shifted = shift.isShifted() == true
    local switched = shifted ~= shown
    shown = shifted

    local events = {}
    for _, light in ipairs(newLights) do
      local place = placeOf[light.control]
      local onShiftLayer = place ~= nil
      if not onShiftLayer then
        place = light.control
      end
      local shared = layer[place] ~= nil
      if shared then
        remember(light)
      end
      -- when Shift has been pressed or let go, every shared place is
      -- delivered below
      if not shared or (onShiftLayer == shifted and not switched) then
        table.insert(events, makeColourEvent(place, light.colour, light.behaviour))
      end
    end

    if switched then
      for _, place in ipairs(places) do
        local control = place
        if shifted then
          control = layer[place]
        end
        local remembered = control and lights[control]
        if remembered then
          for _, light in ipairs(remembered) do
            table.insert(events, makeColourEvent(place, light.colour, light.behaviour))
          end
        else
          table.insert(events, makeColourEvent(place, col.config.off))
        end
      end
    end

    return events
  end

  return self
end

-- one Shift layer for each device, so that what is pressed and what is lit
-- go through the same one
local instances = {}

return function(device)
  if not instances[device] then
    instances[device] = new(device)
  end
  return instances[device]
end
