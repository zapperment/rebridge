local config = require("src.lib.debug.config")
local hex = require("src.lib.hex._")

return function(msg)
  local event = config.debugSysexHeader .. " " .. hex.textToHex(msg) .. "F7"
  return remote.make_midi(event)
end
