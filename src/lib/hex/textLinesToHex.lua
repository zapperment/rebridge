return function(str)
  local lines = {}
  for line in (str .. "\n"):gmatch("(.-)\n") do
    table.insert(lines, line)
  end

  local hexLines = {}
  for _, line in ipairs(lines) do
    local bytes = {}
    for i = 1, #line do
      local byte = string.byte(line, i)
      table.insert(bytes, string.format("%02x", byte))
    end
    table.insert(hexLines, table.concat(bytes, " "))
  end

  return hexLines
end
