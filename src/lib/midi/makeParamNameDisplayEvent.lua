local textToHex = require("src.lib.hex.textToHex")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")

return function(text, target)
  return makeSysexEvent("06 xx 00 " .. textToHex(text), { x = target })
end
