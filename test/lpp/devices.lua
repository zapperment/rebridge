-- the devices the shared tests in test/lpp run for, each with the suffix of
-- the names of its test classes
return {
  { suffix = "MK3", device = require "src.lppmk3.device" },
  { suffix = "MK2", device = require "src.lppmk2.device" },
}
