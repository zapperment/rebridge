local const = require "src.config.constants"
local tbl = require "src.lib.table._"

-- what the Launchpad Pro [MK2] and [MK3] codecs have in common; each device
-- adds its own in its config/constants.lua
return tbl.merge(const, {
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
