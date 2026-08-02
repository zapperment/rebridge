local state = require("src.lib.state._")
local items = require("src.config.items")
local const = require("src.config.constants")
local midi = require("src.lib.midi._")
local deb = require("src.lib.debug._")

-- called regularly by the codec to update the control surface (Launch Control)
return function()
  local events = {}
  for i = 1, const.counts.faders do
    local fader = "fader" .. i
    local hostTextValueChanged = state.hasChanged(fader .. ".hostTextValue")
    local paramChanged = state.hasChanged(fader .. ".param")
    local hostTextValue = state.update(fader .. ".hostTextValue")
    local param = state.update(fader .. ".param")
    state.update(fader .. ".hostValue")
    local enabled = state.update(fader .. ".enabled")
    local statusChanged = state.hasChanged(fader .. ".status")
    local status = state.update(fader .. ".status")
    local controller = items[fader].controller
    if hostTextValueChanged or paramChanged then
      table.insert(events,
        midi.makeParamDisplayConfigEvent(controller, enabled, midi.displayArrangements.nameAndTextValue))
    end
    if enabled then
      if paramChanged then
        table.insert(events, midi.makeParamNameDisplayEvent(param, controller))
      end
      if hostTextValueChanged or statusChanged then
        local prefix = ""
        local suffix = ""
        if status == const.fader.tooHigh then
          prefix = "v "
          suffix = " v"
        end
        if status == const.fader.tooLow then
          prefix = "^ "
          suffix = " ^"
        end
        table.insert(events, midi.makeParamValueDisplayEvent(prefix .. hostTextValue .. suffix, controller))
      end
    end
  end
  return events
end
