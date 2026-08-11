local items = require("src.config.items")
local state = require("src.lib.state._")
local deb = require("src.lib.debug._")
local str = require("src.lib.string._")

return function(control, event, callback)
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
      return false
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
