local state = require("src.lib.state._")
local pages = require("src.lib.state.pages")
local pageNames = require("src.config.pageNames")
local makeOverlayDisplayEvents = require("src.lib.midi.makeOverlayDisplayEvents")

-- called regularly by the codec to update the remote surface (Launch Control);
-- shows the number and name of the page just switched to on the overlay
-- display, which reverts to the stationary display after the timeout
return function()
  if not pages.consumeDisplay() then
    return {}
  end
  local names = pageNames[state.getNext("deviceType")]
  local name = names and names[pages.active]
  return makeOverlayDisplayEvents("Page " .. pages.active, name or " ")
end
