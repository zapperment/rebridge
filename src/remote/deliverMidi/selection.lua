local col = require "src.lcxl3.lib.colour._"
local ctrl = require "src.lcxl3.config.controls"
local items = require "src.lcxl3.config.items"
local midi = require "src.lcxl3.lib.midi._"
local state = require "src.lib.state._"

-- asks the surface for its mode, so that it replies with a MIDI event the codec
-- can switch the mapping in force on (see processMidi/selection and ADR 0003):
-- feature controls are queried on channel 8
local surfaceModeQueryMidi = "b7 1e 00"

local onValue = "On"
local offValue = "Off"
local brightIntensity = 95
local dimIntensity = 1

-- the events that show a selection button as standing for the given option, lit
-- brightly while its option is selected and dimly otherwise; it does not bring
-- up its display when pressed, as the overlay shows the selection that follows
local function showOption(events, control, option, selected, refresh)
  local item = items[control]
  local controller = item.controller
  if refresh then
    table.insert(events, midi.makeParamDisplayConfigEvent(
      controller, false, midi.displayArrangements.nameAndTextValue
    ))
    table.insert(events, midi.makeParamNameDisplayEvent(state.getOptionLabel(option), controller))
  end
  local isSelected = option == selected
  table.insert(events, midi.makeParamValueDisplayEvent(isSelected and onValue or offValue, controller))
  table.insert(events, midi.makeColourEvent(
    state.getSelectionColour(item.colour),
    isSelected and brightIntensity or dimIntensity,
    controller
  ))
end

local function hideOption(events, control)
  local controller = items[control].controller
  table.insert(events, midi.makeParamDisplayConfigEvent(
    controller, false, midi.displayArrangements.nameAndTextValue
  ))
  table.insert(events, midi.makeColourEvent("black", 0, controller))
end

-- called regularly by the codec to update the remote surface (Launch Control);
-- lights up the selection buttons of a selecting device and shows a change of
-- its selection on the overlay display
return function()
  local events = {}
  local enabled, enabledChanged = state.update "selection.enabled"
  local selected, selectedChanged = state.update "selection.selected"
  local count, countChanged = state.update "selection.count"
  state.set("selection.deviceType", state.get "deviceType")
  local _, deviceTypeChanged = state.update "selection.deviceType"

  if state.consumeSelectionPing() then
    table.insert(events, remote.make_midi(surfaceModeQueryMidi))
  end

  if not enabled then
    if enabledChanged then
      -- the buttons go back to the parameters the new device maps to them, whose
      -- LEDs and displays have to be delivered again, even if unchanged
      for _, control in ipairs(ctrl.selectionButtons) do
        state.forceUpdate(control .. ".enabled")
      end
    end
    return events
  end

  local refresh = enabledChanged or countChanged or deviceTypeChanged
  for option, control in ipairs(ctrl.selectionButtons) do
    if option <= count then
      if refresh or selectedChanged then
        showOption(events, control, option, selected, refresh)
      end
      if state.isDisplayForced(control) then
        table.insert(events, midi.makeParamDisplayTriggerEvent(items[control].controller))
      end
    elseif refresh then
      hideOption(events, control)
    end
  end

  if selectedChanged and not refresh then
    for _, event in ipairs(midi.makeOverlayDisplayEvents(state.getSelectorName(), state.getOptionLabel(selected))) do
      table.insert(events, event)
    end
  end
  return events
end
