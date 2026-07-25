local items = require("src.config.items")
local state = require("src.lib.state._")

-- handles presses of the play and record buttons of the remote surface (Launch Control)
return function(event)
  local match = remote.match_midi(items.playButton.midi, event)
  if match then
    if match.x > 0 then
      -- Reason's "Play" remotable can only start playback (trig),
      -- so when Reason is already playing, trigger "Stop" instead
      local item = state.get("transport.playing") and items.stopButton or items.playButton
      remote.handle_input({ time_stamp = event.time_stamp, item = item.index, value = 1 })
    end
    return true
  end

  match = remote.match_midi(items.recordButton.midi, event)
  if match then
    if match.x > 0 then
      -- Reason's "Record" remotable is a toggle, a press flips it
      remote.handle_input({ time_stamp = event.time_stamp, item = items.recordButton.index, value = 1 })
    end
    return true
  end

  return false
end
