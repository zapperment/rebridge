local config = require("src.lib.debug.config")
local textToHex = require("src.lib.hex.textToHex")

return function(msg)
  local event = config.debugSysexHeader .. " " .. textToHex(msg) .. "F7"
  return remote.make_midi(event)
end
