local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"

-- handles presses of the play button of the remote surface (Launchpad)
return function(event)
  local match = remote.match_midi(items.playButton.midi, event)
  if not match then
    return false
  end
  if match.x > 0 then
    -- Reason's "Play" remotable can only start playback (trig),
    -- so when Reason is already playing, trigger "Stop" instead
    local item = state.get "transport.playing" and items.stopButton or items.playButton
    remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = 1 })
  end
  return true
end
