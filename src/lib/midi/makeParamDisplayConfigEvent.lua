local makeSysexEvent = require("src.lib.midi.makeSysexEvent")

-- Configures a control's own display. Bits 0-4 hold the display arrangement, 4
-- being the default of parameter name plus numeric value. Bit 6 lets the Launch
-- Control bring that display up by itself when the control is changed, bit 5
-- when it is touched; both are set by default. The arrangement has to stay
-- non-zero for those bits to take effect, as a config of zero merely cancels
-- whatever the display currently shows.
local arrangement = 0x04
local automatic = 0x60

-- With the automatic display switched off, moving the control shows nothing at
-- all, which is what a control the host has not assigned a parameter to needs:
-- clearing the parameter name would still leave the raw value on show.
return function(target, automaticDisplay)
  local config = automaticDisplay and arrangement + automatic or arrangement
  return makeSysexEvent("04 xx " .. string.format("%02x", config), { x = target })
end
