local state = require("src.lib.state._")
local items = require("src.config.items")
local const = require("src.config.constants")
local midi = require("src.lib.midi._")
local deb = require("src.lib.debug._")

-- called regularly by the codec to update the remote surface (Launch Control)
return function()
  local events = {}
  for i = 1, const.counts.encoders do
    local control = "encoder" .. i

    local _, controlSurfaceValueChanged = state.update(control .. ".controlSurfaceValue")
    local enabled, enabledChanged = state.update(control .. ".enabled")
    local param, paramChanged = state.update(control .. ".param")
    local hostValue = state.update(control .. ".hostValue")
    local hostTextValue, hostTextValueChanged = state.update(control .. ".hostTextValue")
    local colour, colourChanged = state.update(control .. ".colour")

    local item = items[control]
    local controller = item.controller

    if control == "encoder4" and (enabledChanged or paramChanged or hostTextValueChanged or colourChanged) then
      deb.log("[remote:deliverMidi:encoders] " .. control .. ".enabled=" .. (enabled and "true" or "false") ..
        " (" .. (enabledChanged and "" or "not ") .. "changed)")
      deb.log("[remote:deliverMidi:encoders] " .. control .. ".param=" .. param ..
        " (" .. (paramChanged and "" or "not ") .. "changed)")
      deb.log("[remote:deliverMidi:encoders] " .. control .. ".hostTextValue=" .. hostTextValue ..
        " (" .. (hostTextValueChanged and "" or "not ") .. "changed)")
      deb.log("[remote:deliverMidi:encoders] " .. control .. ".colour=" .. colour ..
        " (" .. (colourChanged and "" or "not ") .. "changed)")
    end

    if enabledChanged or hostTextValueChanged or paramChanged then
      local displayConfigEvent = midi.makeParamDisplayConfigEvent(controller, enabled,
        midi.displayArrangements.nameAndTextValue)
      table.insert(events, displayConfigEvent)
      if control == "encoder4" then
        deb.log(
          "[remote:deliverMidi:encoders] set display mode for " .. control ..
          ": " .. deb.midiEventToString(displayConfigEvent))
      end
    end
    if enabled then
      if paramChanged then
        table.insert(events, midi.makeParamNameDisplayEvent(param, controller))
      end
      if hostTextValueChanged then
        table.insert(events, remote.make_midi(item.midi, { x = hostValue }))
        table.insert(events, midi.makeParamValueDisplayEvent(hostTextValue, item.controller))
      end
      if control == "encoder4" and (hostTextValueChanged or paramChanged) then
        deb.log("[remote:deliverMidi:encoders] delivered param value display for " ..
          control .. ": " .. param .. "=" .. hostTextValue)
      end
      if colourChanged then
        table.insert(events, midi.makeSysexEvent("01 53 xx " .. colour, { x = item.controller }))
      end
      if controlSurfaceValueChanged then
        table.insert(events, midi.makeParamDisplayTriggerEvent(controller))
      end
    else
      -- turn off encoder's LED
      table.insert(events, midi.makeSysexEvent("01 53 xx 00 00 00", { x = item.controller }))
    end
  end
  return events
end
