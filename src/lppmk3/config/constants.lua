local const = require "src.config.constants"
local tbl = require "src.lib.table._"

return tbl.merge(const, {
  softwareVersion = "0.0.1 BETA",
  sysexHeader = "f0 00 20 29 02 0e",
  counts = {
    pads = 64,
  }
})
