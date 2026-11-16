local const = require "src.lpcommon.config.constants"
local hex = require "src.lib.hex._"
local address = require "src.lpmk2.lib.midi.address"

-- makes the event that lights the pad or button at the place given (see
-- address.lua) in the colour given, an entry of the palette the surface
-- shares with the later Launchpads. The light is set by the message of its
-- pad or button; the behaviour (static, flashing, pulsing) determines the
-- MIDI channel of the message, as on the later Launchpads: channel 1 is
-- static, 2 is flashing, 3 is pulsing. Nothing for a place the surface has
-- nothing at.
return function(place, colour, behaviour)
  local status, number = address.addressOf(place)
  if not status then
    return nil
  end
  status = status + (behaviour or const.colourBehaviour.static) - 1
  return remote.make_midi(hex.decToHex(status) .. " " .. hex.decToHex(number) .. " " .. hex.decToHex(colour))
end
