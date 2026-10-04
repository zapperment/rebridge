local items = require "src.lppmk3.config.items"
local deb = require "src.lib.debug._"

return function(event)
  local logMe = true
  local processed = false
  local ret = remote.match_midi("xx yy zz", event)
  if ret and ret.z > 0 then
    local track = nil
    local slot = nil
    if ret.x == 144 then
      -- note on message from the 8x8 pad grid
      track = ret.y % 10
      slot = 9 - ((ret.y - track) / 10)
    elseif ret.x == 176 and ret.y >= 101 and ret.y <= 108 then
      -- control change message from the track buttons
      track = ret.y - 100
      slot = 0
    end
    if track and slot then
      local item = items["track" .. track .. "slot"]
      if logMe then
        deb.log(
          "[lppmk3:remote:processMidi:trackSlots] " ..
          "track=" .. track .. " / " ..
          "slot=" .. slot .. " / " ..
          "item.index=" .. item.index
        )
      end
      remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = slot })
      processed = true
    end
  end
  return processed
end
