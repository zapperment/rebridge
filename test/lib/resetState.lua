local state = require("src.lib.state._")
local const = require("src.config.constants")

return function()
  for i = 1, 8 do
    state.set("fader" .. i, const.fader.unassigned)
  end
  for i = 1, 24 do
    state.set("encoder" .. i .. ".value", 0)
    state.set("encoder" .. i .. ".colour", "00 00 00")
    state.set("encoder" .. i .. ".enabled", false)
  end
  for i = 1, 16 do
    state.set("button" .. i .. ".value", 0)
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
