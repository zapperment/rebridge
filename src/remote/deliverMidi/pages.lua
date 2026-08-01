local state = require("src.lib.state._")
local pages = require("src.lib.state.pages")
local pageNames = require("src.config.pageNames")
local midi = require("src.lib.midi._")
local deb = require("src.lib.debug._")

-- called regularly by the codec to update the remote surface (Launch Control);
-- shows the number and name of the page just switched to on the overlay
-- display, which reverts to the stationary display after the timeout
return function()
  if not pages.consumeDisplay() then
    return {}
  end
  local names = pageNames[state.getNext("deviceType")]
  local name = names and names[pages.active]
  deb.log("[remote.deliverMidi.pages] deviceType=" ..
    state.getNext("deviceType") .. ", name=" .. (name or "nil") .. ", pages.active=" .. pages.active)
  return midi.makeOverlayDisplayEvents("Page " .. pages.active, name or " ")
end
