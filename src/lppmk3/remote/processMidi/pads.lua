local state = require "src.lppmk3.lib.state._"
local deb = require "src.lib.debug._"
local items = require "src.lppmk3.config.items"
local col = require "src.lppmk3.lib.colour._"

-- handles changes of the buttons of the remote surface (Launchpad): on their
-- own, the pads select the patterns; pressing the playing pad stops it, unless
-- another pattern is pending, which it then cancels; pressing a pending pad
-- does nothing; with Shift held down, the playing and the pending pad cycle
-- through the colours of their pattern, while the other pads do nothing
return function(event)
  local logMe = false
  local processed = false
  local ret = remote.match_midi("90 xx yy", event)
  if ret and ret.y ~= 0 then
    local patternValue = ret.x % 10
    local deviceIndex = 9 - ((ret.x - patternValue) / 10)
    local device = "device" .. deviceIndex
    if logMe then
      deb.log(
        "[lppmk3:remote:processMidi:pads] " ..
        "deviceIndex=" .. deviceIndex .. " / " ..
        "patternValue=" .. patternValue
      )
    end
    local hostValue = state.get(device .. ".hostValue")
    local playingValue = state.get(device .. ".playingValue")
    if state.isShifted() then
      if hostValue ~= patternValue and playingValue ~= patternValue then
        return true
      end
      local colourPath = device .. ".colour" .. patternValue
      local colour = col.nextPatternColour(state.get(colourPath))
      if logMe then
        deb.log(
          "[lppmk3:remote:processMidi:pads] " ..
          "colour=" .. colour
        )
      end
      state.set(colourPath, colour)
      -- the colours are to be stored, and a reply to an earlier request would
      -- now be out of date
      state.set("store.dirty", true)
      state.set("store.awaitingReply", false)
      return true
    end
    if logMe then
      deb.log(
        "[lppmk3:remote:processMidi:pads] " ..
        "hostValue=" .. hostValue
      )
    end
    local nextHostValue = patternValue
    if hostValue == patternValue then
      if hostValue ~= playingValue then
        return true
      end
      nextHostValue = 0
    end
    if logMe then
      deb.log(
        "[lppmk3:remote:processMidi:pads] " ..
        "nextHostValue=" .. nextHostValue
      )
    end
    local item = items[device]
    remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = nextHostValue })
    processed = true
  end
  return processed
end
