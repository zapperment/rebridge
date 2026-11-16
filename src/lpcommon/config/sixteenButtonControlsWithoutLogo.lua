local controls = require "src.lpcommon.config.sixteenButtonControls"
local tbl = require "src.lib.table._"

-- The controls of the Launchpads that came before the [MK3] generation and
-- have sixteen buttons around their pads: the Launchpad Mini and the
-- Launchpad MK2. Their buttons are in the same places as those of the
-- Launchpad Mini [MK3], so the controls are the same (see
-- sixteenButtonControls.lua; each device turns what its surface sends into
-- those numbers). They have no logo that lights up: the Session button,
-- which stands for the setup button, shows the mode colour instead.
return tbl.merge(controls, {
  logo = controls.setup,
})
