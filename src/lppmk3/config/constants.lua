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
  -- input ports are numbered separately from output ports; the surface sends
  -- its pads and buttons on its MIDI port (input port 1, as above) and its
  -- layout reports, which is all the Setup button produces, on its DAW port
  inputPorts = {
    daw = 2,
  },
  -- for how many milliseconds after the codec has switched the surface to
  -- programmer mode a layout report counts as the answer to that switch
  setupButtonQuietTime = 2000,
  colourBehaviour = {
    static = 1,
    flashing = 2,
    pulsing = 3,
  }
})
