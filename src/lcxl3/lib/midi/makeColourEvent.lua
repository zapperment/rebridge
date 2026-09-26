local col = require "src.lcxl3.lib.colour._"
local makeSysexEvent = require "src.lcxl3.lib.midi.makeSysexEvent"
local deb = require "src.lib.debug._"
local str = require "src.lib.string._"

return function(colourName, intensity, controller)
  local logMe = false --controller == 35
  local colour = col.getColour(colourName, intensity);
  if logMe then
    deb.log(
      "[lib.midi.makeColourEvent] " ..
      "colour: " .. str.serialise(colour)
    )
  end
  return makeSysexEvent("01 53 xx " .. colour, { x = controller })
end
