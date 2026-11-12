local const = require "src.lpp.config.constants"
local makeProcessShift = require "src.lpp.remote.processMidi.shift"
local processTransport = require "src.lpp.remote.processMidi.transport"
local makeProcessLaunchnik = require "src.lpp.remote.processMidi.launchnik"

-- makes the handler of the MIDI of the remote surface (Launchpad) given (see
-- src/lppmk3/device.lua): pads and buttons arrive on its MIDI port; what
-- arrives on another port is the device's to handle, if it handles any, and
-- is swallowed otherwise: a port used in both directions, like an IAC bus,
-- sends back whatever the codec sends to it, and the colour events of the
-- buttons would otherwise count as presses of them
return function(device)
  local processShift = makeProcessShift(device)
  local processLaunchnik = makeProcessLaunchnik(device)

  return function(event)
    if event.port ~= const.ports.surface then
      if device.processOtherPort then
        device.processOtherPort(event)
      end
      return true
    end
    return processShift(event) or processTransport(event) or processLaunchnik.processPadsAndTrackButtons(event)
  end
end
