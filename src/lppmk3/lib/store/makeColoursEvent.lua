local const = require "src.lppmk3.config.constants"
local hex = require "src.lib.hex._"
local encodeName = require "src.lppmk3.lib.store.encodeName"

-- sends the surface store the colours of the given song and LaunchEon: the
-- colour of each pattern, device by device
return function(documentName, deviceName, colours)
  local parts = {
    const.store.sysexHeader,
    hex.decToHex(const.store.commands.colours),
    encodeName(documentName),
    encodeName(deviceName),
  }
  for _, colour in ipairs(colours) do
    table.insert(parts, hex.decToHex(colour))
  end
  table.insert(parts, "f7")
  return remote.make_midi(table.concat(parts, " "))
end
