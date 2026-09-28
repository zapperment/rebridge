local tbl = require "src.lib.table._"
local col = require "src.lib.colour._"

return tbl.merge(col, {
  config = require "src.lppmk3.lib.colour.config",
  nextPatternColour = require "src.lppmk3.lib.colour.nextPatternColour",
  unselectedPatternColour = require "src.lppmk3.lib.colour.unselectedPatternColour",
});
