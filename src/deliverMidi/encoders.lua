local state = require("src.lib.state._")
local items = require("src.config.items")
local const = require("src.config.constants")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")
local makeParamNameDisplayEvent = require("src.lib.midi.makeParamNameDisplayEvent")
local makeParamValueDisplayEvent = require("src.lib.midi.makeParamValueDisplayEvent")
local makeParamDisplayConfigEvent = require("src.lib.midi.makeParamDisplayConfigEvent")
local arrangements = require("src.lib.midi.displayArrangements")
local getLabel = require("src.lib.valueLabels.getLabel")
local getConditionalLabel = require("src.lib.valueLabels.getConditionalLabel")
local getInterpolatedValue = require("src.lib.valueLabels.getInterpolatedValue")
local debug = require("src.lib.debug._")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, const.counts.encoders do
    local path, enabled, changed
    local item = items["encoder" .. i]

    path = "encoder" .. i .. ".enabled"
    if state.hasChanged(path) then
      enabled = state.update(path)
      changed = true
      if enabled then
        -- let the encoder bring up its display again; the codec provides the
        -- value text, so that the display shows the value in the parameter's
        -- own range (e.g. -50..50 for Osc Fine Tune) instead of the raw 0-127
        table.insert(events, makeParamDisplayConfigEvent(item.controller, true, arrangements.nameAndTextValue))
      else
        -- turn of encoder's LED
        table.insert(events, makeSysexEvent("01 53 xx 00 00 00", { x = item.controller }))
        -- the parameter name stays on the encoder's display until it is
        -- overwritten, so stop the encoder bringing that display up while it is
        -- disabled; otherwise moving it shows the previous name and a raw value
        table.insert(events, makeParamDisplayConfigEvent(item.controller, false))
      end
    else
      enabled = state.get(path)
    end

    if enabled then
      path = "encoder" .. i .. ".value"
      if changed or state.hasChanged(path) then
        local value = state.update(path)
        table.insert(events, remote.make_midi(item.midi, { x = value }))
        local paramName = remote.get_item_name(item.index)
        table.insert(events, makeParamNameDisplayEvent(paramName, item.controller))
        local deviceType = state.get("deviceType")
        local itemState = remote.get_item_state(item.index)
        local displayValue = getConditionalLabel(deviceType, paramName, value)
            or getLabel(deviceType, paramName, itemState)
            or getInterpolatedValue(deviceType, paramName, itemState.value)
            or itemState.text_value
        table.insert(events, makeParamValueDisplayEvent(displayValue, item.controller))
      end
      path = "encoder" .. i .. ".colour"
      if changed or state.hasChanged(path) then
        local colour = state.update(path)
        table.insert(events, makeSysexEvent("01 53 xx " .. colour, { x = item.controller }))
      end
    end
  end
  return events
end
