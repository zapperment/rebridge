local state = require("src.lib.state._")
local buttonStates = require("src.lib.state.buttons")
local faderStates = require("src.lib.state.faders")
local paramValues = require("src.lib.state.paramValues")
local shiftState = require("src.lib.state.shift")
local pages = require("src.lib.state.pages")
local const = require("src.config.constants")

return function()
  pages.reset()
  buttonStates.pressed = nil
  buttonStates.held = {}
  shiftState.held = false
  for param in pairs(paramValues) do
    paramValues[param] = nil
  end
  for i = 1, const.counts.faders do
    state.set("fader" .. i, const.fader.unassigned)
    faderStates["fader" .. i] = {}
  end
  for i = 1, const.counts.encoders do
    state.set("encoder" .. i .. ".value", 0)
    state.set("encoder" .. i .. ".colour", "00 00 00")
    state.set("encoder" .. i .. ".enabled", false)
  end
  for i = 1, const.counts.buttons do
    state.set("button" .. i .. ".value", false)
    state.set("button" .. i .. ".colour", "00 00 00")
    state.set("button" .. i .. ".enabled", false)
  end
  state.set("display", " ")
  state.set("documentName", " ")
  state.set("targetTrackName", " ")
  state.set("deviceType", " ")
  state.set("deviceName", " ")
  state.set("patchName", " ")
  state.updateAll()
end
