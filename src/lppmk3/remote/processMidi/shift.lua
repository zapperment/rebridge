local state = require "src.lppmk3.lib.state._"
local deb = require "src.lib.debug._"

-- Shift sends CC 90 on channel 1, with value 127 when pressed and 0 when
-- released
local shiftMidi = "b0 5a xx"

-- handles the Shift button of the remote surface (Launchpad)
return function(event)
  local logMe = false
  local match = remote.match_midi(shiftMidi, event)
  if match then
    state.setShifted(match.x > 0)
    if logMe then
      deb.log(
        "[lppmk3:remote:processMidi:shift] " ..
        "value=" .. match.x .. " / " ..
        "shifted=" .. tostring(state.isShifted())
      )
    end
    return true
  end
  return false
end
