local items = require "src.lpcommon.config.items"
local state = require "src.lpcommon.lib.state._"

-- makes the handler of presses of the play and record buttons of the device
-- given
return function(device)
  local playButton = device.controls.play
  local recordButton = device.controls.record

  return function(input)
    if input.pad then
      return false
    end
    if input.control == playButton then
      if input.value > 0 then
        -- Reason's "Play" remotable can only start playback (trig),
        -- so when Reason is already playing, trigger "Stop" instead
        local item = state.get "transport.playing" and items.stopButton or items.playButton
        remote.handle_input({ time_stamp = input.time_stamp, item = item.index, value = 1 })
      end
      return true
    end
    if input.control == recordButton then
      if input.value > 0 then
        -- Reason's "Record" remotable is a toggle, a press flips it
        remote.handle_input({ time_stamp = input.time_stamp, item = items.recordButton.index, value = 1 })
      end
      return true
    end
    return false
  end
end
