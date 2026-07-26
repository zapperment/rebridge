local makeSysexEvent = require("src.lib.midi.makeSysexEvent")
local textToHex = require("src.lib.hex.textToHex")

local target = "36" -- overlay/temporary display

-- Shows a parameter name and value on the overlay display, which reverts to the
-- stationary display once the temporary display timeout has elapsed. Used for
-- controls that the hardware provides no display target of their own for.
return function(name, value)
  return {
    -- Configure display: arrangement 1 (parameter name and text parameter value)
    makeSysexEvent("04 " .. target .. " 61"),
    makeSysexEvent("06 " .. target .. " 00 " .. textToHex(name)),
    makeSysexEvent("06 " .. target .. " 01 " .. textToHex(value)),
    -- Trigger display
    makeSysexEvent("04 " .. target .. " 7f"),
  }
end
