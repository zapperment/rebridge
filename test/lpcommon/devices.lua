-- the devices the shared tests in test/lpcommon run for, each with the suffix
-- of the names of its test classes
return {
  { suffix = "MK3", device = require "src.lppmk3.device" },
  { suffix = "LPP", device = require "src.lpp.device" },
  { suffix = "LPMMK3", device = require "src.lpmmk3.device" },
  { suffix = "LPX", device = require "src.lpx.device" },
  { suffix = "LPM", device = require "src.lpm.device" },
  { suffix = "LPMK2", device = require "src.lpmk2.device" },
}
