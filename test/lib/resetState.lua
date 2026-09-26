local state = require "src.lcxl3.lib.state._"
local const = require "src.lcxl3.config.constants"
local ctrl = require "src.lcxl3.config.controls"

return function()
  state.resetPages()
  state.resetSelection()
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
  state.set("selection.deviceType", " ")

  for _, control in ipairs(ctrl.encoders) do
    state.set(control .. ".enabled", false)
    state.set(control .. ".displaying", false)
    state.set(control .. ".controlSurfaceValue", 0)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
  end
  for _, control in ipairs(ctrl.faders) do
    state.set(control .. ".enabled", false)
    state.set(control .. ".displaying", false)
    state.set(control .. ".controlSurfaceValue", nil)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
    state.set(control .. ".status", const.fader.unassigned)
    state.setForceDisplay(control .. ".forceDisplay", false)
  end
  for _, control in ipairs(ctrl.buttons) do
    state.set(control .. ".enabled", false)
    state.set(control .. ".controlSurfaceValue", false)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
    state.set(control .. ".type", const.button.toggle)
    state.setForceDisplay(control .. ".forceDisplay", false)
  end
  for _, control in ipairs(ctrl.rackUIs) do
    state.set(control .. ".enabled", false)
    state.set(control .. ".param", nil)
    state.set(control .. ".hostValue", nil)
    state.set(control .. ".hostTextValue", "")
  end
  state.updateAll()
end
