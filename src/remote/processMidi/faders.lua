local items = require("src.config.items")
local const = require("src.config.constants")
local state = require("src.lib.state._")
local deb = require("src.lib.debug._")

-- handles changes of the faders of the control surface (Launch Control)
return function(event)
  local processed = false

  for i = 1, const.counts.faders do
    local fader = "fader" .. i
    local ret = remote.match_midi(items[fader].midi, event)
    if ret then
      local controlSurfaceValue = ret.x
      state.set(fader .. ".controlSurfaceValue", controlSurfaceValue)
      local hostValue = state.get(fader .. ".hostValue")
      local status = state.getNext(fader .. ".status")
      if status == const.fader.unknown then
        -- it is goes here when the codec has just been loaded and
        -- we receive a CC from a fader for the first time
        if controlSurfaceValue >= hostValue - const.pickupTolerance and controlSurfaceValue <= hostValue + const.pickupTolerance then
          status = const.fader.inSync
        elseif controlSurfaceValue < hostValue then
          status = const.fader.tooLow
        elseif controlSurfaceValue > hostValue then
          status = const.fader.tooHigh
        end
      elseif status == const.fader.tooLow then
        if controlSurfaceValue >= hostValue then
          status = const.fader.inSync
        end
      elseif status == const.fader.tooHigh then
        if controlSurfaceValue <= hostValue then
          status = const.fader.inSync
        end
      end
      state.set(fader .. ".status", status)
      state.set(fader .. ".controlSurfaceValue", controlSurfaceValue)
      if status == const.fader.inSync then
        remote.handle_input({
          item = items[fader].index,
          value = controlSurfaceValue,
          time_stamp = event.time_stamp
        })
        processed = true
      end
    end
  end
  return processed
end
