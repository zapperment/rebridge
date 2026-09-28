local state = require "src.lppmk3.lib.state._"

-- whether a change of pattern waits for the next switch point, which is only
-- the case while the transport is playing and the Pattern Timer is on;
-- otherwise, LaunchEon switches at once
return function()
  return state.get "transport.playing" and state.get "patternTimer" ~= 0
end
