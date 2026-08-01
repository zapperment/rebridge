local faderStates = require("src.lib.state.faders")
local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local debug = require("src.lib.debug._")

-- handles changes of the faders of the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, const.counts.faders do
    local fader = "fader" .. i
    local ret = remote.match_midi(items[fader].midi, event)
    if ret then
      local remoteSurfaceValue = ret.x
      local hostValue = faderStates[fader].host
      local status = state.get(fader)
      if status == const.fader.unknown then
        -- it is goes here when the codec has just been loaded and
        -- we receive a CC from a fader for the first time
        if remoteSurfaceValue >= hostValue - const.pickupTolerance and remoteSurfaceValue <= hostValue + const.pickupTolerance then
          state.set(fader, const.fader.inSync)
        elseif remoteSurfaceValue < hostValue then
          state.set(fader, const.fader.tooLow)
        elseif remoteSurfaceValue > hostValue then
          state.set(fader, const.fader.tooHigh)
        end
      elseif status == const.fader.tooLow then
        if remoteSurfaceValue >= hostValue then
          state.set(fader, const.fader.inSync)
        end
      elseif status == const.fader.tooHigh then
        if remoteSurfaceValue <= hostValue then
          state.set(fader, const.fader.inSync)
        end
      end
      faderStates[fader].remoteSurface = remoteSurfaceValue

      if state.getNext(fader) == const.fader.inSync then
        faderStates[fader].host = remoteSurfaceValue

        -- CODEC => REASON
        remote.handle_input({
          item = items[fader].index,
          value = remoteSurfaceValue,
          time_stamp = event.time_stamp
        })
        processed = true
      end
    end
  end
  if processed then
    debug.log("[processMidi.faders] LCXL3 => CODEC")
  end
  return processed
end
