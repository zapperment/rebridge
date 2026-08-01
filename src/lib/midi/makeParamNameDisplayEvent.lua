local hex = require("src.lib.hex._")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")

return function(text, target)
  return makeSysexEvent("06 xx 00 " .. hex.textToHex(text), { x = target })
end
