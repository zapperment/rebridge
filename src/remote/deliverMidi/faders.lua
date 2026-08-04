local state = require("src.lib.state._")
local items = require("src.config.items")
local const = require("src.config.constants")
local midi = require("src.lib.midi._")
local deb = require("src.lib.debug._")

-- called regularly by the codec to update the control surface (Launch Control)
return function()
  local events = {}
  for i = 1, const.counts.faders do
    local control = "fader" .. i

    local controlSurfaceValueChanged = state.hasChanged(control .. ".controlSurfaceValue")
    state.update(control .. ".controlSurfaceValue")

    local enabledChanged = state.hasChanged(control .. ".enabled")
    local enabled = state.update(control .. ".enabled")

    local paramChanged = state.hasChanged(control .. ".param")
    local param = state.update(control .. ".param")

    state.update(control .. ".hostValue")

    local hostTextValueChanged = state.hasChanged(control .. ".hostTextValue")
    local hostTextValue = state.update(control .. ".hostTextValue")

    local statusChanged = state.hasChanged(control .. ".status")
    local status = state.update(control .. ".status")

    local controller = items[control].controller

    if control == "fader1" and (hostTextValueChanged or paramChanged or statusChanged) then
      deb.log("[remote:deliverMidi:faders] " .. control .. ".enabled=" .. (enabled and "true" or "false") ..
        " (" .. (enabledChanged and "" or "not ") .. "changed)")
      deb.log("[remote:deliverMidi:faders] " .. control .. ".param=" .. param ..
        " (" .. (paramChanged and "" or "not ") .. "changed)")
      deb.log("[remote:deliverMidi:faders] " .. control .. ".hostTextValue=" .. hostTextValue ..
        " (" .. (hostTextValueChanged and "" or "not ") .. "changed)")
      deb.log("[remote:deliverMidi:faders] " .. control .. ".status=" .. status ..
        " (" .. (statusChanged and "" or "not ") .. "changed)")
    end

    if hostTextValueChanged or paramChanged or statusChanged then
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
        if control == "fader1" and (hostTextValueChanged or paramChanged or statusChanged) then
          deb.log("[remote:deliverMidi:faders] delivered param value display: " .. prefix .. hostTextValue .. suffix)
        end
      end
      if controlSurfaceValueChanged then
        table.insert(events, midi.makeParamDisplayTriggerEvent(controller))
      end
    end
  end
  return events
end
