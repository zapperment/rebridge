local const = require "src.config.constants"
local tbl = require "src.lib.table._"

return tbl.merge(const, {
  softwareVersion = "0.0.1 BETA",
  sysexHeader = "f0 00 20 29 02 0e",
  -- the MIDI ports of the codec: the Launchpad itself and, in the dev version
  -- only, the log
  ports = {
    surface = 1,
    log = 2,
  },
  colourBehaviour = {
    static = 1,
    flashing = 2,
    pulsing = 3,
  }
})
