local faderStates = require("src.lib.state.faders")
local items = require("src.config.items")
local constants = require("src.config.constants")
local stateUtils = require("src.lib.state.utils")

-- handles changes of the faders from the remote surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, 8 do
    local fader = "fader" .. i
    local ret = remote.match_midi(items[fader].midi, event)
    if ret then
      local remoteSurfaceValue = ret.x
      local hostValue = faderStates[fader].host
      local state = stateUtils.get(fader)
      if state == constants.fader.unknown then
        -- it is goes here when the codec has just been loaded and
        -- we receive a CC from a fader for the first time
        if remoteSurfaceValue >= hostValue - constants.pickupTolerance and remoteSurfaceValue <= hostValue + constants.pickupTolerance then
          stateUtils.set(fader, constants.fader.inSync)
        elseif remoteSurfaceValue < hostValue then
          stateUtils.set(fader, constants.fader.tooLow)
        elseif remoteSurfaceValue > hostValue then
          stateUtils.set(fader, constants.fader.tooHigh)
        end
      elseif state == constants.fader.tooLow then
        if remoteSurfaceValue >= hostValue then
          stateUtils.set(fader, constants.fader.inSync)
        end
      elseif state == constants.fader.tooHigh then
        if remoteSurfaceValue <= hostValue then
          stateUtils.set(fader, constants.fader.inSync)
        end
      end
      faderStates[fader].remoteSurface = remoteSurfaceValue

      if stateUtils.getNext(fader) == constants.fader.inSync then
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

  return processed
end
