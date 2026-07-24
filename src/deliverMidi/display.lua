local stateUtils = require("src.lib.state.utils")

local function textToHex(str)
  local lines = {}
  for line in (str .. "\n"):gmatch("(.-)\n") do
    table.insert(lines, line)
  end

  local hex_lines = {}
  for _, line in ipairs(lines) do
    local bytes = {}
    for i = 1, #line do
      local byte = string.byte(line, i)
      table.insert(bytes, string.format("%02x", byte))
    end
    table.insert(hex_lines, table.concat(bytes, " "))
  end

  return hex_lines
end

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  if stateUtils.hasChanged("display") then
    local text = stateUtils.update("display")
    -- Configure display: arrangement 2 (3 lines)
    table.insert(events, remote.make_midi("f0 00 20 29 02 15 04 35 62 f7"))

    local target = "35" -- stationary display
    local lines = textToHex(text)

    for field, hex in ipairs(lines) do
      local fieldByte = string.format("%02x", field - 1) -- 00h, 01h, 02h...
      table.insert(events, remote.make_midi(
        "f0 00 20 29 02 15 06 " .. target .. " " .. fieldByte .. " " .. hex .. " f7"
      ))
    end

    -- Trigger display
    table.insert(events, remote.make_midi("f0 00 20 29 02 15 04 35 7f f7"))
  end
  return events
end
