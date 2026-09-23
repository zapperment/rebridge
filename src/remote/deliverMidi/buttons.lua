local col = require "src.lib.colour._"
local ctrl = require "src.lcxl3.config.controls"
local const = require "src.lcxl3.config.constants"
local disp = require "src.lib.display._"
local items = require "src.lcxl3.config.items"
local midi = require "src.lib.midi._"
local state = require "src.lib.state._"
local str = require "src.lib.string._"
local deb = require "src.lib.debug._"

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for _, control in ipairs(ctrl.buttons) do
    -- the selection buttons of a selecting device belong to its selection,
    -- which lights them up (see deliverMidi/selection)
    if not state.isSelectionButton(control) then
      local logMe = false --control == "button8"
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
      if logMe and hostValueChanged then
        deb.log(
          "[remote.deliverMidi.buttons] " ..
          "(/) new host value: *" .. str.serialise(hostValue) .. "*"
        )
      end

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
          local displayName = disp.getDisplayName(deviceType, param)
          table.insert(events, midi.makeParamNameDisplayEvent(displayName, controller))
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
          -- button down: light up button LED; a cycle or momentary button is
          -- bright only while it is held down
          if type ~= const.button.toggle then
            local intensity = controlSurfaceValue > 0 and 95 or 1
            local colourName = col.getColourName(deviceType, param, item.colour)
            table.insert(events, midi.makeColourEvent(colourName, intensity, controller))
            buttonLightHandled = true
          end
        end

        -- the LED has to be lit again whenever a button comes back into use, and
        -- whenever it changes the parameter it is mapped to: switching to a
        -- device without buttons turns the LED off, and switching back reports
        -- the same host value as before, which on its own would leave the LED off
        if not buttonLightHandled and (hostValueChanged or enabledChanged or paramChanged) then
          if logMe then
            local isButtonToggle = type == const.button.toggle and "true" or "false"
            deb.log(
              "[remote.deliverMidi.buttons] " ..
              "is button toggle? " .. isButtonToggle
            )
          end
          local intensity = 1
          if type == const.button.toggle and hostValue then
            intensity = 95
            if logMe then
              deb.log(
                "[remote.deliverMidi.buttons] " ..
                "has host value, setting intensity " .. intensity
              )
            end
          else
            if logMe then
              deb.log(
                "[remote.deliverMidi.buttons] " ..
                "has no host value, setting intensity " .. intensity
              )
            end
          end
          local colourName = col.getColourName(deviceType, param, item.colour)
          table.insert(events, midi.makeColourEvent(colourName, intensity, controller))
        end
      elseif enabledChanged then
        -- turn off button's LED if it is disabled
        if logMe then
          deb.log(
            "[remote.deliverMidi.buttons] " ..
            "enabled changed to disabled, turning LED off"
          )
        end
        table.insert(events, midi.makeColourEvent("black", 0, controller))
      end
    end
  end

  return events
end
