local const = require "src.lppmk3.config.constants"

local headerBytes = { 0xf0, 0x7d, 0x52, 0x42 }

-- reads a name written by the surface store (see encodeName), returning it and
-- the position after it, or nil if the message ends too soon
local function readName(event, position)
  local length = event[position]
  if length == nil or position + 2 * length >= event.size then
    return nil
  end
  local bytes = {}
  for i = 1, length do
    local high = event[position + 2 * i - 1]
    local low = event[position + 2 * i]
    table.insert(bytes, string.char(high * 16 + low))
  end
  return table.concat(bytes), position + 2 * length + 1
end

-- the message of the surface store in the given MIDI event, as a table with
-- its command and, depending on the command, the names of the song and
-- LaunchEon and the colours; nil for anything else
return function(event)
  if event.size == nil or event.size < #headerBytes + 2 then
    return nil
  end
  for i, byte in ipairs(headerBytes) do
    if event[i] ~= byte then
      return nil
    end
  end
  local message = { command = event[#headerBytes + 1] }
  if message.command == const.store.commands.hello then
    return message
  end
  local position = #headerBytes + 2
  message.documentName, position = readName(event, position)
  if message.documentName == nil then
    return nil
  end
  message.deviceName, position = readName(event, position)
  if message.deviceName == nil then
    return nil
  end
  if message.command == const.store.commands.colours then
    message.colours = {}
    for i = position, event.size - 1 do
      table.insert(message.colours, event[i])
    end
  end
  return message
end
