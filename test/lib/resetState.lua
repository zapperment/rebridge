local state = require "src.lib.state._"
local const = require "src.config.constants"

return function()
  state.resetPages()
  state.setShifted(false)
  state.resetHostValues()

  state.set("transport.playing", false)
  state.set("transport.recording", false)
  state.set("display", " ")
  state.set("documentName", " ")
  state.set("targetTrackName", " ")
  state.set("deviceType", " ")
  state.set("deviceName", " ")
  state.set("patchName", " ")

  local control
  for i = 1, const.counts.encoders do
    control = "encoder" .. i
    state.set(control .. ".enabled", false)
    state.set(control .. ".controlSurfaceValue", 0)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
    control = "encoder" .. i .. "alt"
    state.set(control .. ".enabled", false)
    state.set(control .. ".controlSurfaceValue", 0)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
  end
  for i = 1, const.counts.faders do
    control = "fader" .. i
    state.set(control .. ".enabled", false)
    state.set(control .. ".controlSurfaceValue", 0)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
    state.set(control .. ".status", const.fader.unassigned)
    state.setForceDisplay(control .. ".forceDisplay", false)
    control = "fader" .. i .. "alt"
    state.set(control .. ".enabled", false)
    state.set(control .. ".controlSurfaceValue", 0)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
    state.set(control .. ".status", const.fader.unassigned)
    state.setForceDisplay(control .. ".forceDisplay", false)
  end
  for i = 1, const.counts.buttons do
    control = "button" .. i
    state.set(control .. ".enabled", false)
    state.set(control .. ".controlSurfaceValue", false)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
    state.set(control .. ".type", const.button.toggle)
    state.setForceDisplay(control .. ".forceDisplay", false)
  end
  state.updateAll()
end
