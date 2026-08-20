local col = require "src.lib.colour._"
local ctrl = require "src.config.controls"
local const = require "src.config.constants"
local disp = require "src.lib.display._"
local items = require "src.config.items"
local midi = require "src.lib.midi._"
local state = require "src.lib.state._"
local deb = require "src.lib.debug._"

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for _, control in ipairs(ctrl.buttons) do
    local isDisplayForced = state.isDisplayForced(control)
    local deviceType = state.update "deviceType"
    local controlSurfaceValue, controlSurfaceValueChanged = state.update(control .. ".controlSurfaceValue")
    local enabled, enabledChanged = state.update(control .. ".enabled")
    local param, paramChanged = state.update(control .. ".param")
    local hostValue, hostValueChanged = state.update(control .. ".hostValue")
    local _, hostTextValueChanged = state.update(control .. ".hostTextValue")
    local type = state.update(control .. ".type")

    local item = items[control]
    local controller = item.controller

    if enabledChanged or hostTextValueChanged or paramChanged then
      local displayConfigEvent = midi.makeParamDisplayConfigEvent(
        controller, enabled,
        midi.displayArrangements.nameAndTextValue
      )
      table.insert(events, displayConfigEvent)
    end
    if enabled then
      -- display the parameter name briefly in the LCD if it has changed
      if paramChanged then
        table.insert(events, midi.makeParamNameDisplayEvent(param, controller))
      end

      -- if the value has changed, display it in the LCD briefly and report the
      -- new value back to the control surface via MIDI CC
      if hostValueChanged or hostTextValueChanged then
        local displayValue = disp.getButtonDisplayValue(control)
        table.insert(events, midi.makeParamValueDisplayEvent(displayValue, controller))
        table.insert(events, remote.make_midi(item.midi, { x = hostValue }))
      end

      local buttonLightHandled = false

      -- control surface value changed means user started holding the button
      -- down
      if (controlSurfaceValueChanged and controlSurfaceValue > 0) or isDisplayForced then
        -- trigger LCD update
        table.insert(events, midi.makeParamDisplayTriggerEvent(controller))
      end

      if controlSurfaceValueChanged then
        -- button down: light up button LED
        if type == const.button.cycle then
          local intensity = controlSurfaceValue > 0 and 95 or 1
          local colourName = col.getColourName(deviceType, param, item.colour)
          table.insert(events, midi.makeColourEvent(colourName, intensity, controller))
          buttonLightHandled = true
        end
      end

      if not buttonLightHandled and hostValueChanged then
        local intensity = 1
        if type == const.button.toggle and hostValue then
          intensity = 95
        end
        local colourName = col.getColourName(deviceType, param, item.colour)
        table.insert(events, midi.makeColourEvent(colourName, intensity, controller))
      end
    elseif enabledChanged then
      -- turn off button's LED if it is disabled
      table.insert(events, midi.makeColourEvent("black", 0, controller))
    end
  end

  return events
end
