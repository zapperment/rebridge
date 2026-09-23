local const = require "src.config.constants"
local tbl = require "src.lib.table._"

local lcConst = {
  softwareVersion = "0.0.10 BETA",
  -- the number of encoders, faders and buttons on the remote surface
  counts = {
    encoders = 24,
    faders = 8,
    buttons = 16,
    pageSelects = 13,
    -- the options a selecting device can have, one per selection button
    options = 8,
    rackUIs = 2,
  },
  sysexHeader = "f0 00 20 29 02 15",
  pickupTolerance = 10,
}

local lcConstAndGlobalConst = tbl.merge(const, lcConst)

return lcConstAndGlobalConst
