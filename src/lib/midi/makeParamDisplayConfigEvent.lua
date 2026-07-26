local makeSysexEvent = require("src.lib.midi.makeSysexEvent")
local arrangements = require("src.lib.midi.displayArrangements")

-- Bits 0-4 of the config byte hold the display arrangement (see
-- displayArrangements); it has to stay non-zero, as a config of zero merely
-- cancels whatever the display currently shows.
--
-- Bit 6 lets the Launch Control bring the display up by itself when the
-- control is changed, bit 5 when it is touched; both are set by default. With
-- the automatic display switched off, moving the control shows nothing at all,
-- which is what a control the host has not assigned a parameter to needs:
-- clearing the parameter name would still leave the raw value on show.
local automatic = 0x60

return function(target, automaticDisplay, arrangement)
  local config = arrangement or arrangements.nameAndNumericValue
  if automaticDisplay then
    config = config + automatic
  end
  return makeSysexEvent("04 xx " .. string.format("%02x", config), { x = target })
end
