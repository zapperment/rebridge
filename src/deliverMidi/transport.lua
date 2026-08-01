local state = require("src.lib.state._")
local items = require("src.config.items")
local makeSysexEvent = require("src.lib.midi.makeSysexEvent")
local debug = require("src.lib.debug._")

-- called regularly by the codec to update the play and record button LEDs
return function()
  local events = {}

  if state.hasChanged("transport.playing") then
    local playing = state.update("transport.playing")
    local colour = playing and "00 7f 00" or "00 00 00"
    table.insert(events, makeSysexEvent("01 53 xx " .. colour, { x = items.playButton.controller }))
  end

  if state.hasChanged("transport.recording") then
    local recording = state.update("transport.recording")
    local colour = recording and "7f 00 00" or "00 00 00"
    table.insert(events, makeSysexEvent("01 53 xx " .. colour, { x = items.recordButton.controller }))
  end
  if #events > 0 then
    debug.log("[deliverMidi.transport] CODEC => LCXL3")
  end
  return events
end
