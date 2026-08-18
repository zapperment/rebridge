local state = require "src.lib.state._"
local midi = require "src.lib.midi._"
local deb = require "src.lib.debug._"

-- called regularly by the codec to update the remote surface (Launch Control);
-- shows the number and name of the page just switched to on the overlay
-- display, which reverts to the stationary display after the timeout
return function()
  if not state.consumePageDisplay() then
    return {}
  end
  local label, name = state.getPageLabelAndName()
  return midi.makeOverlayDisplayEvents(label, name)
end
