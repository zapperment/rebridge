local makeSysexEvent = require("src.lib.midi.makeSysexEvent")

return function(target)
  return makeSysexEvent("04 xx 7f", { x = target })
end
