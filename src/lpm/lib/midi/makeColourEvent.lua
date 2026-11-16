local const = require "src.lpcommon.config.constants"
local hex = require "src.lib.hex._"
local address = require "src.lpm.lib.midi.address"
local ledColour = require "src.lpm.lib.midi.ledColour"

-- The surface keeps two copies of what its LEDs show and, once told to flash
-- (see ../../device.lua), shows them in turn. A light says which copies it
-- is written to:
local flags = {
  -- both, so that it stands still
  [const.colourBehaviour.static] = 12,
  -- one only: it flashes between the colour given and the one the LED shows,
  -- as on the later Launchpads
  [const.colourBehaviour.flashing] = 0,
  -- one, with the other one cleared: it flashes between the colour given and
  -- dark, which is the nearest the surface gets to pulsing
  [const.colourBehaviour.pulsing] = 8,
}

-- makes the event that lights the pad or button at the place given (see
-- address.lua) in the colour given, an entry of the palette of the later
-- Launchpads (see ledColour.lua); nothing for a place the surface has
-- nothing at
return function(place, colour, behaviour)
  local status, number = address.addressOf(place)
  if not status then
    return nil
  end
  local red, green = ledColour(colour)
  local velocity = 16 * green + red + flags[behaviour or const.colourBehaviour.static]
  return remote.make_midi(hex.decToHex(status) .. " " .. hex.decToHex(number) .. " " .. hex.decToHex(velocity))
end
