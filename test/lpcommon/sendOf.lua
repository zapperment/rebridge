local surface = require "src.lpcommon.lib.surface._"

local noteOn = 144
local controlChange = 176

-- the status and number of the MIDI message that the device given sends for
-- the pad or button at the place given: its own, if it numbers them in its
-- own way (see src/lpm/lib/midi/address.lua), and otherwise a note for a pad
-- and a control change for a button, with the number of the place
return function(device, place)
  if device.midi.addressOf then
    return device.midi.addressOf(place)
  end
  return surface.isPad(place) and noteOn or controlChange, place
end
