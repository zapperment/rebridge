local items = require("src.config.items")
local state = require("src.lib.state._")
local deb = require("src.lib.debug._")
local str = require("src.lib.string._")

-- @param callbackWithForcedDisplay - set to true is the callback should
--                                    be executed even though the display
--                                    is forced, which means controller
--                                    interactions cause no actual changes
--                                    because the shift button was pressed
--                                    when the control changed; for buttons,
--                                    we skip the callback; for faders, we
--                                    need to execute it, so we call it with
--                                    callbackWithForcedDisplay=true;
--                                    default value is false
return function(control, event, callback, callbackWithForcedDisplay)
  if callbackWithForcedDisplay == nil then
    callbackWithForcedDisplay = false
  end
  local logMe = true
  local item = items[control]
  local match = remote.match_midi(item.midi, event)
  if match then
    if state.isShifted() then
      if logMe then
        deb.log(
          "[remote:processMidi:process] " ..
          "forcing display for " .. str.serialise(control)
        )
      end
      state.forceDisplay(control)
      if not callbackWithForcedDisplay then
        return false
      end
    end
    local controlSurfaceValue = match.x
    state.set(control .. ".controlSurfaceValue", controlSurfaceValue)
    if state.get(control .. ".enabled") then
      callback(control, controlSurfaceValue, item)
    end
    return true
  end
  return false
end
