local hex = require "src.lib.hex._"

-- the longest name, in bytes, that fits in the length byte of a message
local maxLength = 127

-- a name as it goes into a message of the surface store: its length, then
-- each of its bytes as two nibbles, as sysex data can only carry 7 bits, while
-- names can hold any character
return function(name)
  local length = math.min(string.len(name), maxLength)
  local parts = { hex.decToHex(length) }
  for i = 1, length do
    local byte = string.byte(name, i)
    table.insert(parts, hex.decToHex(math.floor(byte / 16)))
    table.insert(parts, hex.decToHex(byte % 16))
  end
  return table.concat(parts, " ")
end
