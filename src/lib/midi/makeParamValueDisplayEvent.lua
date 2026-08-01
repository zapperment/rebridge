local hex = require("src.lib.hex._")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")

-- Fills the text value field (field 1) of a control's display, shown as the
-- second line by the nameAndTextValue arrangement (see displayArrangements)
return function(text, target)
  return makeSysexEvent("06 xx 01 " .. hex.textToHex(text), { x = target })
end
