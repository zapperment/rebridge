local items = require "src.lppmk3.config.items"
local deb = require "src.lib.debug._"
local spike = require "src.lppmk3.spike.state"

-- the surface reports its layout whenever it changes; releasing the Setup
-- button makes it report the programmer layout (xx = 11h)
local layoutReportMidi = "f0 00 20 29 02 0e 00 xx yy 00 f7"
local programmerLayout = 17
local sysexStart = 240
local noteOn = 144
local colourCount = 14

local function write(event, item, value)
  deb.log("[spike] writing " .. item .. " = " .. value)
  remote.handle_input({ time_stamp = event.time_stamp, item = items[item].index, value = value })
end

-- THROWAWAY: logs every SysEx message of the surface, and while the Launchnik
-- Spike device is mapped, lets the first three pads of the top row and the
-- Setup button write its properties:
--   pad 81 switches the clip on and off
--   pad 82 moves on to the next colour
--   pad 83 and the Setup button switch between launch mode and clip picking
return function(event)
  if event.size and event[1] == sysexStart then
    deb.log("[spike] sysex " .. deb.midiEventToString(event))
  end
  if not spike.enabled then
    return false
  end

  local report = remote.match_midi(layoutReportMidi, event)
  if report then
    if report.x == programmerLayout then
      write(event, "spikeSetup", spike.setup == 0 and 1 or 0)
    end
    return true
  end

  local pad = remote.match_midi("xx yy zz", event)
  if pad and pad.x == noteOn and pad.z > 0 then
    if pad.y == 81 then
      write(event, "spikeClipPresent", spike.present == 0 and 1 or 0)
      return true
    elseif pad.y == 82 then
      write(event, "spikeClipColour", (spike.colour + 1) % colourCount)
      return true
    elseif pad.y == 83 then
      write(event, "spikeSetup", spike.setup == 0 and 1 or 0)
      return true
    end
  end
  return false
end
