local textToHex = require("src.lib.hex.textToHex")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")

-- Fills the text value field (field 1) of a control's display, shown as the
-- second line by the nameAndTextValue arrangement (see displayArrangements)
return function(text, target)
  return makeSysexEvent("06 xx 01 " .. textToHex(text), { x = target })
end
