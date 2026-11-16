local controls = require "src.lpcommon.config.sixteenButtonControls"
local tbl = require "src.lib.table._"

-- The surface has the sixteen buttons of the Launchpad Mini [MK3] in the
-- same places, so its controls are the same (see
-- src/lpcommon/config/sixteenButtonControls.lua; lib/midi/address.lua turns
-- what the surface sends into those numbers). It has no logo that lights up:
-- the Session button, which stands for the setup button, shows the mode
-- colour instead.
return tbl.merge(controls, {
  logo = controls.setup,
})
