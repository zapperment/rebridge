local const = require "src.lppmk3.config.constants"
local hex = require "src.lib.hex._"
local encodeName = require "src.lppmk3.lib.store.encodeName"

-- asks the surface store for the colours of the given song and LaunchEon
return function(documentName, deviceName)
  return remote.make_midi(table.concat({
    const.store.sysexHeader,
    hex.decToHex(const.store.commands.request),
    encodeName(documentName),
    encodeName(deviceName),
    "f7",
  }, " "))
end
