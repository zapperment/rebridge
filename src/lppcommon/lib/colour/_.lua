local tbl = require "src.lib.table._"
local col = require "src.lib.colour._"

return tbl.merge(col, {
  config = require "src.lppcommon.lib.colour.config",
});
