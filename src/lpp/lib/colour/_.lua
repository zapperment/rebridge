local tbl = require "src.lib.table._"
local col = require "src.lib.colour._"

return tbl.merge(col, {
  config = require "src.lpp.lib.colour.config",
});
