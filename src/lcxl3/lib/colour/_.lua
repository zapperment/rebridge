local tbl = require "src.lib.table._"
local col = require "src.lib.colour._"

return tbl.merge(col, {
  getColourName = require "src.lcxl3.lib.colour.getColourName",
});
