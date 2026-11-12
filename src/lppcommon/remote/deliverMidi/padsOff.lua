local col = require "src.lppcommon.lib.colour._"

-- makes the events that turn off every pad of the 8x8 grid of the device
-- given and the scene button to the right of each row, row by row from the
-- top, then the back button, the forward button, the fill-in button and the
-- setup button, if it sends MIDI; the Launchpad keeps them lit for as long as
-- it is powered, so without these events, what the last session left lit
-- would stay lit, although nothing lights it
return function(device)
  local controls = device.controls
  local makeColourEvent = device.midi.makeColourEvent

  return function()
    local events = {}
    for row = 8, 1, -1 do
      -- the scene button continues the numbering of the pads in its row
      for column = 1, 9 do
        table.insert(events, makeColourEvent(row * 10 + column, col.config.off))
      end
    end
    for _, button in ipairs({ controls.back, controls.forward, controls.fillIn }) do
      table.insert(events, makeColourEvent(button, col.config.off))
    end
    if controls.setup then
      table.insert(events, makeColourEvent(controls.setup, col.config.off))
    end
    return events
  end
end
