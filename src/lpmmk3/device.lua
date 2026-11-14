local const = require "src.lpmmk3.config.constants"
local makeDevice = require "src.lpcommon.sixteenButtonDevice"

-- What sets the Launchpad Mini [MK3] apart from the other Launchpads; the
-- codec and its parts in src/lpcommon are made from it.
return makeDevice {
  id = "LPMMK3",
  name = "Novation Launchpad Mini [MK3]",
  const = const,
}
