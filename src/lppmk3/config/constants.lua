local const = require "src.lppcommon.config.constants"
local tbl = require "src.lib.table._"

return tbl.merge(const, {
  softwareVersion = "0.0.1 BETA",
  sysexHeader = "f0 00 20 29 02 0e",
  -- input ports are numbered separately from output ports; the surface sends
  -- its pads and buttons on its MIDI port (input port 1, ports.surface) and
  -- its layout reports, which is all the Setup button produces, on its DAW
  -- port
  inputPorts = {
    daw = 2,
  },
  -- for how many milliseconds after the codec has switched the surface to
  -- programmer mode a layout report counts as the answer to that switch
  setupButtonQuietTime = 2000,
})
