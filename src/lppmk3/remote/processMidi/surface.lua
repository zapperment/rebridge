local const = require "src.lppmk3.config.constants"
local processShift = require "src.lppmk3.remote.processMidi.shift"
local processTransport = require "src.lppmk3.remote.processMidi.transport"
local processTrackSlots = require "src.lppmk3.remote.processMidi.trackSlots"
local processSpike = require "src.lppmk3.spike.processMidi"

-- handles the MIDI of the remote surface (Launchpad): pads and buttons arrive
-- on its MIDI port, layout reports on its DAW port; anything else arriving on
-- another port is swallowed: a port used in both directions, like an IAC bus,
-- sends back whatever the codec sends to it, and the colour events of the
-- buttons would otherwise count as presses of them
return function(event)
  if event.port == const.inputPorts.daw then
    processSpike(event)
    return true
  end
  if event.port ~= const.ports.surface then
    return true
  end
  return processShift(event) or processTransport(event) or processSpike(event) or processTrackSlots(event)
end
