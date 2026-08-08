local state = require("src.lib.state._")
local items = require("src.config.items")
local const = require("src.config.constants")
local midi = require("src.lib.midi._")
local col = require("src.lib.colour._")
local deb = require("src.lib.debug._")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, const.counts.buttons do
    local control = "button" .. i

    local deviceType = state.update("deviceType")
    local controlSurfaceValue, controlSurfaceValueChanged = state.update(control .. ".controlSurfaceValue")
    local enabled, enabledChanged = state.update(control .. ".enabled")
    local param, paramChanged = state.update(control .. ".param")
    local hostValue, hostValueChanged = state.update(control .. ".hostValue")
    local hostTextValue, hostTextValueChanged = state.update(control .. ".hostTextValue")
    local type = state.update(control .. ".type")
    --local colour, colourChanged = state.update(control .. ".colour")

    local item = items["button" .. i]
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
      if hostTextValueChanged then
        table.insert(events, midi.makeParamValueDisplayEvent(hostTextValue, item.controller))
        table.insert(events, remote.make_midi(item.midi, { x = hostValue }))
      end
      -- if colourChanged then
      --   table.insert(events, midi.makeSysexEvent("01 53 xx " .. colour, { x = controller }))
      -- end

      local buttonLightHandled = false

      -- control surface value changed means user started holding the button
      -- down
      if controlSurfaceValueChanged then
        if controlSurfaceValue > 0 then
          -- trigger LCD update
          table.insert(events, midi.makeParamDisplayTriggerEvent(controller))
        end

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
