local state = require "src.lpp.lib.state._"

-- makes the handler of the Shift button of the device given, which sends its
-- control change on channel 1, with value 127 when pressed and 0 when released
return function(device)
  local shiftMidi = string.format("b0 %02x xx", device.controls.shift)

  return function(event)
    local match = remote.match_midi(shiftMidi, event)
    if match then
      state.setShifted(match.x > 0)
      return true
    end
    return false
  end
end
