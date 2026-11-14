local const = require "src.lpx.config.constants"
local makeDevice = require "src.lpcommon.sixteenButtonDevice"

-- What sets the Launchpad X apart from the other Launchpads; the codec and
-- its parts in src/lpcommon are made from it.
return makeDevice {
  id = "LPX",
  name = "Novation Launchpad X",
  const = const,
}
