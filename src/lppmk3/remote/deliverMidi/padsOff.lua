local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"

-- the events that turn off every pad of the 8x8 grid and the scene button to
-- the right of each row, row by row from the top, then the back button; the
-- Launchpad keeps them lit for as long as it is powered, so without these
-- events, what the last session left lit would stay lit, although nothing
-- lights it
return function()
  local events = {}
  for row = 8, 1, -1 do
    -- the scene button continues the numbering of the pads in its row
    for column = 1, 9 do
      table.insert(events, midi.makeColourEvent(row * 10 + column, col.config.off))
    end
  end
  -- the back button, with the arrow pointing left beside Shift
  table.insert(events, midi.makeColourEvent(91, col.config.off))
  return events
end
