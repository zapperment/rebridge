local state = require "src.lpcommon.lib.state._"

-- makes the handler of the Shift button of the device given, which is held
-- for as long as its button on the surface is
return function(device)
  local shiftButton = device.controls.shift

  return function(input)
    if input.pad or input.control ~= shiftButton then
      return false
    end
    state.setShifted(input.value > 0)
    return true
  end
end
