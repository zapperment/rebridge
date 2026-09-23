local col = require "src.lcxl3.lib.colour._"
local ctrl = require "src.lcxl3.config.controls"
local disp = require "src.lcxl3.lib.display._"
local midi = require "src.lib.midi._"
local state = require "src.lib.state._"
local str = require "src.lib.string._"
local util = require "src.remote.deliverMidi.util._"
local deb = require "src.lib.debug._"

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  local deviceType, deviceTypeChanged = state.update "deviceType"
  for _, group in ipairs(util.readItemGroups(ctrl.encoders, deviceType)) do
    local controller = group.controller
    local item = group.displayedItem
    local displayingChanged = group.displayingChanged
    local logMe = false --controller == 14
    if logMe and displayingChanged then
      deb.log(
        "[remote:deliverMidi:encoders] " ..
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
      if item.hostValue ~= nil then
        if item.hostValueChanged or item.hostTextValueChanged or displayingChanged then
          local displayValue = disp.getDisplayValue(item.control)
          table.insert(events, midi.makeParamValueDisplayEvent(displayValue, controller))
          table.insert(events, remote.make_midi(item.midi, { x = item.hostValue }))
        end
        if deviceTypeChanged or item.paramChanged or item.hostValueChanged or displayingChanged then
          local colourName = col.getColourName(deviceType, item.param, item.colour)
          table.insert(events, midi.makeColourEvent(colourName, item.hostValue, controller))
        end
      end
      if item.controlSurfaceValueChanged then
        table.insert(events, midi.makeParamDisplayTriggerEvent(controller))
      end
    elseif displayingChanged then
      -- nothing is mapped to the encoder any more, so it neither lights up nor
      -- brings up a display of its own when it is turned
      table.insert(events, midi.makeParamDisplayConfigEvent(
        controller, false, midi.displayArrangements.nameAndTextValue
      ))
      table.insert(events, midi.makeColourEvent("black", 0, controller))
    end
  end
  return events
end
