local const = require("src.config.constants")
local textToHex = require("src.lib.hex.textToHex")

return function(msg)
  local event = const.debugSysexHeader .. " " .. textToHex(msg) .. "F7"
  return remote.make_midi(event)
end
