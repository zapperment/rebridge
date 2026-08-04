local items = require("src.config.items")
local state = require("src.lib.state._")
local deb = require("src.lib.debug._")

return function(control, event, callback)
  local item = items[control]
  local match = remote.match_midi(item.midi, event)
  if match then
    local controlSurfaceValue = match.x
    state.set(control .. ".controlSurfaceValue", controlSurfaceValue)
    if control == "encoder1" then
      deb.log(
        "[remote:processMidi:util:process] next " .. control .. ".controlSurfaceValue=" ..
        state.getNext(control .. ".controlSurfaceValue")
      )
    end
    if state.get(control .. ".enabled") then
      return callback(control, controlSurfaceValue, item)
    end
  end
  return false
end
