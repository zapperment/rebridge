-- the Launchpads with sixteen buttons around their pads, which the tests of
-- src/lpcommon/sixteenButtonDevice.lua run for, each with the suffix of the
-- names of its test classes and the header of its system exclusive messages
return {
  { suffix = "LPMMK3", device = require "src.lpmmk3.device", sysexHeader = "f0 00 20 29 02 0d" },
  { suffix = "LPX", device = require "src.lpx.device", sysexHeader = "f0 00 20 29 02 0c" },
}
