local state = require "src.lppmk3.lib.state._"
local deb = require "src.lib.debug._"
local items = require "src.lppmk3.config.items"

-- handles changes of the buttons of the remote surface (Launchpad)
return function(event)
  local logMe = false
  local processed = false
  local ret = remote.match_midi("90 xx yy", event)
  if ret and ret.y ~= 0 then
    local patternIndex = ret.x % 10
    local patternValue = 9 - ((ret.x - patternIndex) / 10)
    if logMe then
      deb.log(
        "[lppmk3:remote:processMidi:pads] " ..
        "patternIndex=" .. patternIndex .. " / " ..
        "patternValue=" .. patternValue
      )
    end
    local hostValue = state.get("pattern" .. patternIndex .. ".hostValue")
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
    local item = items["pattern" .. patternIndex]
    remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = nextHostValue })
    processed = true
  end
  return processed
end
