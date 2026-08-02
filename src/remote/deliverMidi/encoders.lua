local state = require("src.lib.state._")
local items = require("src.config.items")
local const = require("src.config.constants")
local midi = require("src.lib.midi._")
local disp = require("src.lib.display._")
local deb = require("src.lib.debug._")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, const.counts.encoders do
    local control = "encoder" .. i
    local hostTextValueChanged = state.hasChanged(control .. ".hostTextValue")
    local hostTextValue = state.update(control .. ".hostTextValue")
    local paramChanged = state.hasChanged(control .. ".param")
    local param = state.update(control .. ".param")
    local hostValue = state.update(control .. ".hostValue")
    local enabled = state.update(control .. ".enabled")
    local colourChanged = state.hasChanged(control .. ".colour")
    local colour = state.update(control .. ".colour")
    local item = items[control]
    local controller = item.controller
    if hostTextValueChanged or paramChanged then
      table.insert(events,
        midi.makeParamDisplayConfigEvent(controller, enabled, midi.displayArrangements.nameAndTextValue))
    end
    if enabled then
      if paramChanged then
        table.insert(events, midi.makeParamNameDisplayEvent(param, controller))
      end
      if hostTextValueChanged then
        table.insert(events, remote.make_midi(item.midi, { x = hostValue }))
        table.insert(events, midi.makeParamValueDisplayEvent(hostTextValue, item.controller))
      end
      if colourChanged then
        table.insert(events, midi.makeSysexEvent("01 53 xx " .. colour, { x = item.controller }))
      end
    else
      -- turn off encoder's LED
      table.insert(events, midi.makeSysexEvent("01 53 xx 00 00 00", { x = item.controller }))
    end
  end
  return events
end
