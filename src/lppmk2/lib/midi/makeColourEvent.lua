local const = require "src.lppmk2.config.constants"
local hex = require "src.lib.hex._"
local makeSysexEvent = require "src.lppmk2.lib.midi.makeSysexEvent"

-- in programmer layout the surface does not take flashing and pulsing colours
-- on MIDI channels 2 and 3, as the Launchpad Pro [MK3] does, but by SysEx
-- message; the same messages light any pad or button, the LED on the front
-- edge included, so the codec uses them for static colours too
local commands = {
  [const.colourBehaviour.static] = "0A",
  -- flashes between the colour given and the one the LED shows
  [const.colourBehaviour.flashing] = "23",
  [const.colourBehaviour.pulsing] = "28",
}

return function(controllerNumber, value, behaviour)
  local command = commands[behaviour or const.colourBehaviour.static]
  return makeSysexEvent(command .. " " .. hex.decToHex(controllerNumber) .. " " .. hex.decToHex(value))
end
