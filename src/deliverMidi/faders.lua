local state = require("src.lib.state._")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, 8 do
    local fader = "fader" .. i
    if state.hasChanged(fader) then
      -- currently not sending any fader CCs to remote surface
      -- we may change this later
      state.update(fader)
    end
  end
  return events
end
