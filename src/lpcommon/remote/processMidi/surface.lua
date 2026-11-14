local const = require "src.lpcommon.config.constants"
local surface = require "src.lpcommon.lib.surface._"
local makeProcessShift = require "src.lpcommon.remote.processMidi.shift"
local makeProcessTransport = require "src.lpcommon.remote.processMidi.transport"
local makeProcessLaunchnik = require "src.lpcommon.remote.processMidi.launchnik"

local noteOff = 128
local noteOn = 144
local controlChange = 176

-- makes the handler of the MIDI of the remote surface (Launchpad) given (see
-- src/lppmk3/device.lua): pads and buttons arrive on its MIDI port; what
-- arrives on another port is the device's to handle, if it handles any, and
-- is swallowed otherwise: a port used in both directions, like an IAC bus,
-- sends back whatever the codec sends to it, and the colour events of the
-- buttons would otherwise count as presses of them
--
-- The handlers of the pads and buttons get an input rather than the MIDI
-- event: its time stamp, the control that was pressed or let go (which, with
-- Shift held, need not be the one the device has in that place, see
-- lib/surface/shiftLayer.lua), whether that control is a pad, and the value,
-- which is above 0 for a press and 0 for letting go.
return function(device)
  local shiftLayer = surface.makeShiftLayer(device)
  local processShift = makeProcessShift(device)
  local processTransport = makeProcessTransport(device)
  local processLaunchnik = makeProcessLaunchnik(device)

  return function(event)
    if event.port ~= const.ports.surface then
      if device.processOtherPort then
        device.processOtherPort(event)
      end
      return true
    end
    local ret = remote.match_midi("xx yy zz", event)
    if not ret then
      return false
    end
    local status, value = ret.x, ret.z
    -- a pad that is let go may send a note off rather than a note on with
    -- velocity 0
    if status == noteOff then
      status, value = noteOn, 0
    end
    -- the pads send notes, the buttons control changes
    if status ~= noteOn and status ~= controlChange then
      return false
    end
    if (status == noteOn) ~= surface.isPad(ret.y) then
      return false
    end
    local input = { time_stamp = event.time_stamp, control = ret.y, value = value, pad = status == noteOn }
    if processShift(input) then
      return true
    end
    local control = shiftLayer.translate(ret.y, value)
    if control == false then
      return true
    end
    input.control = control
    input.pad = surface.isPad(control)
    return processTransport(input) or processLaunchnik.processPadsAndTrackButtons(input)
  end
end
