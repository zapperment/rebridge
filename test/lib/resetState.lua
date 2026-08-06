local state = require("src.lib.state._")
local paramValues = require("src.lib.state.paramValues")
local shiftState = require("src.lib.state.shift")
local pages = require("src.lib.state.pages")
local const = require("src.config.constants")

return function()
  pages.reset()
  shiftState.held = false
  for param in pairs(paramValues) do
    paramValues[param] = nil
  end
  for i = 1, const.counts.faders do
    local control = "fader" .. i
    state.set(control .. ".enabled", false)
    state.set(control .. ".controlSurfaceValue", 0)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
    state.set(control .. ".status", const.fader.unassigned)
  end
  for i = 1, const.counts.encoders do
    local control = "encoder" .. i
    state.set(control .. ".enabled", false)
    state.set(control .. ".controlSurfaceValue", 0)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
  end
  for i = 1, const.counts.buttons do
    local control = "button" .. i
    state.set(control .. ".enabled", false)
    state.set(control .. ".controlSurfaceValue", false)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
    state.set(control .. ".type", const.button.toggle)
  end
  state.set("transport.playing", false)
  state.set("transport.recording", false)
  state.set("display", " ")
  state.set("documentName", " ")
  state.set("targetTrackName", " ")
  state.set("deviceType", " ")
  state.set("deviceName", " ")
  state.set("patchName", " ")
  state.updateAll()
end
