return function(event)
  local bytes = {}
  local n = event.size or #event
  for i = 1, n do
    table.insert(bytes, string.format("%02X", event[i]))
  end
  local str = table.concat(bytes, " ")
  if event.port then
    str = str .. string.format(" (port=%d)", event.port)
  end
  return str
end
