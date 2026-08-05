local col = require("src.lib.colour._")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")

return function(colourName, intensity, controller)
  local colour = col.getColour(colourName, intensity);
  return makeSysexEvent("01 53 xx " .. colour, { x = controller })
end
