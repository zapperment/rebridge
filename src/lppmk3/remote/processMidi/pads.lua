local state = require "src.lppmk3.lib.state._"
local deb = require "src.lib.debug._"
local items = require "src.lppmk3.config.items"
local col = require "src.lppmk3.lib.colour._"

-- handles changes of the buttons of the remote surface (Launchpad): on their
-- own, the pads select the patterns; with Shift held down, they cycle through
-- the colours of the pattern they belong to
return function(event)
  local logMe = false
  local processed = false
  local ret = remote.match_midi("90 xx yy", event)
  if ret and ret.y ~= 0 then
    local patternIndex = ret.x % 10
    local patternValue = 9 - ((ret.x - patternIndex) / 10)
    local pattern = "pattern" .. patternIndex
    if logMe then
      deb.log(
        "[lppmk3:remote:processMidi:pads] " ..
        "patternIndex=" .. patternIndex .. " / " ..
        "patternValue=" .. patternValue
      )
    end
    if state.isShifted() then
      local colour = col.nextPatternColour(state.get(pattern .. ".colour"))
      if logMe then
        deb.log(
          "[lppmk3:remote:processMidi:pads] " ..
          "colour=" .. colour
        )
      end
      state.set(pattern .. ".colour", colour)
      return true
    end
    local hostValue = state.get(pattern .. ".hostValue")
    if logMe then
      deb.log(
        "[lppmk3:remote:processMidi:pads] " ..
        "hostValue=" .. hostValue
      )
    end
    local nextHostValue = hostValue == patternValue and 0 or patternValue
    if logMe then
      deb.log(
        "[lppmk3:remote:processMidi:pads] " ..
        "nextHostValue=" .. nextHostValue
      )
    end
    local item = items[pattern]
    remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = nextHostValue })
    processed = true
  end
  return processed
end
