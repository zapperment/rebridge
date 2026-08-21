local col = require "src.lib.colour._"
local const = require "src.config.constants"
local ctrl = require "src.config.controls"
local str = require "src.lib.string._"
local disp = require "src.lib.display._"
local items = require "src.config.items"
local midi = require "src.lib.midi._"
local state = require "src.lib.state._"
local deb = require "src.lib.debug._"

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  local handledControllers = {}
  for _, control in ipairs(ctrl.encoders) do
    local logMe = control == "encoder23" or control == "encoder23alt"
    local deviceType, deviceTypeChanged = state.update "deviceType"
    local _, controlSurfaceValueChanged = state.update(control .. ".controlSurfaceValue")
    local enabled, enabledChanged = state.update(control .. ".enabled")
    local param, paramChanged = state.update(control .. ".param")
    local hostValue, hostValueChanged = state.update(control .. ".hostValue")
    local hostTextValue, hostTextValueChanged = state.update(control .. ".hostTextValue")


    local item = items[control]
    local controller = item.controller
    local shouldDisplay = disp.shouldDisplay(deviceType, param)

    if logMe and hostValueChanged then
      deb.log(
        "[remote:deliverMidi:encoders] " ..
        control .. ", " ..
        "controller=" .. controller .. ", " ..
        "hostValue=" .. hostValue .. ", " ..
        "hostTextValue=" .. hostTextValue .. ", " ..
        "param=" .. param
      )
      if shouldDisplay then
        deb.log(
          "[remote:deliverMidi:encoders] " ..
          "(/) should display!"
        )
      else
        deb.log(
          "[remote:deliverMidi:encoders] " ..
          "(-1) should not display..."
        )
      end
    end
    if shouldDisplay then
      if enabledChanged or hostTextValueChanged or paramChanged then
        local displayConfigEvent = midi.makeParamDisplayConfigEvent(
          controller, enabled,
          midi.displayArrangements.nameAndTextValue
        )
        table.insert(events, displayConfigEvent)
      end
      if enabled then
        if paramChanged then
          table.insert(events, midi.makeParamNameDisplayEvent(param, controller))
        end
        if hostValueChanged or hostTextValueChanged then
          local displayValue = disp.getDisplayValue(control)
          table.insert(events, midi.makeParamValueDisplayEvent(displayValue, controller))
          table.insert(events, remote.make_midi(item.midi, { x = hostValue }))
        end
        if deviceTypeChanged or paramChanged or hostValueChanged then
          local colourName = col.getColourName(
            deviceType,
            param,
            item.colour
          )
          if logMe then
            deb.log(
              "[remote:deliverMidi:encoders] " ..
              "(/) colour: " .. colourName
            )
          end
          table.insert(events, midi.makeColourEvent(colourName, hostValue, controller))
          handledControllers[controller] = true
        end
        if controlSurfaceValueChanged then
          table.insert(events, midi.makeParamDisplayTriggerEvent(controller))
        end
      elseif enabledChanged and not handledControllers[controller] then
        if logMe then
          deb.log(
            "[remote:deliverMidi:encoders] " ..
            "(ox) turning off LED"
          )
        end
        -- turn off encoder's LED
        table.insert(events, midi.makeColourEvent("black", 0, controller))
      end
    end
  end
  return events
end
