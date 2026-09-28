local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"
local timing = require "src.lppmk3.lib.timing._"
local deb = require "src.lib.debug._"

-- handles changes of the Pattern Timer and the transport of the host (Reason):
-- pending patterns start to play at the next switch point, or at once when the
-- transport stops or the timer is turned off
return function(hostItems)
  local logMe = false
  local newSongPosition = nil
  for _, hostItemIndex in ipairs(hostItems) do
    if hostItemIndex == items.patternTimer.index then
      state.set("patternTimer", remote.get_item_state(hostItemIndex).value)
    elseif hostItemIndex == items.playButton.index then
      local changedItem = remote.get_item_state(hostItemIndex)
      state.set("transport.playing", changedItem.is_enabled and changedItem.value > 0)
    elseif hostItemIndex == items.songPosition.index then
      newSongPosition = remote.get_item_state(hostItemIndex).value
    end
  end
  if not timing.canBePending() then
    timing.switchPatterns()
  end
  if newSongPosition == nil then
    return
  end
  if logMe then
    deb.log(
      "[lppmk3.setState.transport] " ..
      "songPosition=" .. newSongPosition
    )
  end
  local previous = state.get "songPosition"
  state.set("songPosition", newSongPosition)
  if previous == nil or not timing.canBePending() then
    return
  end
  local interval = timing.switchInterval(state.get "patternTimer")
  if timing.isSwitchPoint(previous, newSongPosition, interval) then
    timing.switchPatterns()
  end
end
