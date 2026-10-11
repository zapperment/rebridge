local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"

-- the events that turn off every pad of the 8x8 grid, row by row from the top;
-- the Launchpad keeps its pads lit for as long as it is powered, so without
-- them, the pads the last session left lit would stay lit, although nothing
-- lights them
return function()
  local events = {}
  for row = 8, 1, -1 do
    for column = 1, 8 do
      table.insert(events, midi.makeColourEvent(row * 10 + column, col.config.off))
    end
  end
  return events
end
