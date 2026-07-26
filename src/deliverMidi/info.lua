local state = require("src.lib.state._")
local textLinesToHex = require("src.lib.hex.textLinesToHex")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")
local deviceTypeLabels = require("src.config.deviceTypeLabels")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  local deviceName, deviceType, patchName
  local updateDisplay = false
  if state.hasChanged("targetTrackName") then
    state.update("targetTrackName");
  end
  if state.hasChanged("documentName") then
    state.update("documentName");
  end
  if state.hasChanged("deviceType") then
    deviceType = state.update("deviceType");
    updateDisplay = true
  else
    deviceType = state.get("deviceType")
  end
  if state.hasChanged("deviceName") then
    deviceName = state.update("deviceName");
    updateDisplay = true
  else
    deviceName = state.get("deviceName")
  end
  if state.hasChanged("patchName") then
    patchName = state.update("patchName");
    updateDisplay = true
  else
    patchName = state.get("patchName")
  end
  if updateDisplay then
    -- Configure display: arrangement 2 (3 lines)
    table.insert(events, makeSysexEvent("04 35 62"))

    local target = "35" -- stationary display
    local lines = (deviceTypeLabels[deviceType] or "") ..
    "\n" .. deviceName .. "\n" .. (patchName == deviceName and "" or patchName)
    local hexLines = textLinesToHex(lines)

    for field, hex in ipairs(hexLines) do
      local fieldByte = string.format("%02x", field - 1) -- 00h, 01h, 02h...
      table.insert(events, makeSysexEvent(
        "06 " .. target .. " " .. fieldByte .. " " .. hex
      ))
    end

    -- Trigger display
    table.insert(events, makeSysexEvent("04 35 7f"))
  end
  return events
end
