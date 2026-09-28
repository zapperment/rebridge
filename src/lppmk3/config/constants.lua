local const = require "src.config.constants"
local tbl = require "src.lib.table._"

return tbl.merge(const, {
  softwareVersion = "0.0.1 BETA",
  sysexHeader = "f0 00 20 29 02 0e",
  counts = {
    pads = 64,
    devices = 8,
    -- the patterns a device can play (not counting 0 for none), one per pad
    patternValues = 8,
    -- the buttons of the switch meter, one per step
    switchMeterButtons = 8,
  },
  -- the length of one 4/4 bar in the units of the host's song position
  songPositionPerBar = 61440,
  -- the switch interval in bars for each value of LaunchEon's Pattern Timer;
  -- 0 (off) has none, the pattern switches at once
  switchIntervalBars = { 1 / 4, 1 / 2, 1, 2, 4 },
  colourBehaviour = {
    static = 1,
    flashing = 2,
    pulsing = 3,
  }
})
