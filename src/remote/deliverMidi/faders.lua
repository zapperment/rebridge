local const = require "src.config.constants"
local ctrl = require "src.config.controls"
local disp = require "src.lib.display._"
local items = require "src.config.items"
local midi = require "src.lib.midi._"
local state = require "src.lib.state._"
local deb = require "src.lib.debug._"

-- called regularly by the codec to update the control surface (Launch Control)
return function()
  local events = {}
  for _, control in ipairs(ctrl.faders) do
    local deviceType = state.update "deviceType"
    local _, controlSurfaceValueChanged = state.update(control .. ".controlSurfaceValue")
    local enabled, enabledChanged = state.update(control .. ".enabled")
    local param, paramChanged = state.update(control .. ".param")
    state.update(control .. ".hostValue")
    local _, hostTextValueChanged = state.update(control .. ".hostTextValue")
    local status, statusChanged = state.update(control .. ".status")

    local controller = items[control].controller

    if disp.shouldDisplay(deviceType, param) then
      if enabledChanged or hostTextValueChanged or paramChanged then
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
          local displayValue = disp.getDisplayValue(control)
          table.insert(events, midi.makeParamValueDisplayEvent(prefix .. displayValue .. suffix, controller))
        end
        if controlSurfaceValueChanged then
          table.insert(events, midi.makeParamDisplayTriggerEvent(controller))
        end
      end
    end
  end
  return events
end
