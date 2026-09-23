local const = require "src.lcxl3.config.constants"
local ctrl = require "src.lcxl3.config.controls"
local disp = require "src.lcxl3.lib.display._"
local midi = require "src.lcxl3.lib.midi._"
local state = require "src.lcxl3.lib.state._"
local str = require "src.lib.string._"
local util = require "src.remote.deliverMidi.util._"
local deb = require "src.lib.debug._"

-- next to what every control has, a fader keeps the pickup status that decides
-- which way the fader has to be moved to catch up with the parameter's value
local function readStatus(item, control)
  item.status, item.statusChanged = state.update(control .. ".status")
end

-- the arrows a fader shows around its value while it has not caught up with the
-- value the parameter is at
local function getPickupMarkers(status)
  if status == const.fader.tooHigh then
    return "v ", " v"
  end
  if status == const.fader.tooLow then
    return "^ ", " ^"
  end
  return "", ""
end

-- called regularly by the codec to update the control surface (Launch Control)
return function()
  local events = {}
  local deviceType = state.update "deviceType"
  for _, group in ipairs(util.readItemGroups(ctrl.faders, deviceType, readStatus)) do
    local controller = group.controller
    local item = group.displayedItem
    local displayingChanged = group.displayingChanged
    local logMe = false --controller == 5
    if logMe and displayingChanged then
      deb.log(
        "[remote:deliverMidi:faders] " ..
        "controller=" .. controller .. " " ..
        "now shows " .. (item and str.serialise(item.control) or "nothing")
      )
    end
    if item then
      if displayingChanged or item.hostTextValueChanged or item.paramChanged then
        table.insert(events, midi.makeParamDisplayConfigEvent(
          controller, true, midi.displayArrangements.nameAndTextValue
        ))
      end
      -- an item that takes over from another one has to send everything again,
      -- as its own values have not necessarily changed while it was not on show
      if (item.paramChanged or displayingChanged) and item.param then
        local displayName = disp.getDisplayName(deviceType, item.param)
        table.insert(events, midi.makeParamNameDisplayEvent(displayName, controller))
      end
      if item.hostValue ~= nil and (item.hostTextValueChanged or item.statusChanged or displayingChanged) then
        local prefix, suffix = getPickupMarkers(item.status)
        local displayValue = disp.getDisplayValue(item.control)
        table.insert(events, midi.makeParamValueDisplayEvent(prefix .. displayValue .. suffix, controller))
      end
      if item.controlSurfaceValueChanged then
        table.insert(events, midi.makeParamDisplayTriggerEvent(controller))
      end
    elseif displayingChanged then
      -- nothing is mapped to the fader any more, so moving it brings up no
      -- display of its own
      table.insert(events, midi.makeParamDisplayConfigEvent(
        controller, false, midi.displayArrangements.nameAndTextValue
      ))
    end
  end
  return events
end
