local const = require "src.lpcommon.config.constants"
local hex = require "src.lib.hex._"

-- makes the event that lights a pad or button of a Launchpad of the [MK3]
-- generation, which in programmer mode takes the colour of any of them as a
-- control change; the behaviour (static, flashing, pulsing) determines the
-- MIDI channel of the control change message: channel 1 is static, 2 is
-- flashing, 3 is pulsing
return function(controllerNumber, value, behaviour)
  if not behaviour then
    behaviour = const.colourBehaviour.static
  end
  local status = 0xB0 + behaviour - 1
  return remote.make_midi(hex.decToHex(status) .. " " .. hex.decToHex(controllerNumber) .. " " .. hex.decToHex(value))
end
