local state = require("src.lib.state._")
local textLinesToHex = require("src.lib.hex.textLinesToHex")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")
local debug = require("src.lib.debug._")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  if state.hasChanged("display") then
    local text = state.update("display")
    -- Configure display: arrangement 2 (3 lines)
    table.insert(events, makeSysexEvent("04 35 62"))

    local target = "35" -- stationary display
    local lines = textLinesToHex(text)

    for field, hex in ipairs(lines) do
      local fieldByte = string.format("%02x", field - 1) -- 00h, 01h, 02h...
      table.insert(events, makeSysexEvent(
        "06 " .. target .. " " .. fieldByte .. " " .. hex
      ))
    end

    -- Trigger display
    table.insert(events, makeSysexEvent("04 35 7f"))
  end

  if #events > 0 then
    debug.log("[deliverMidi.display] CODEC => LCXL3")
  end
  return events
end
