local ctrl = require "src.lcxl3.config.controls"
local const = require "src.lcxl3.config.constants"
local state = require "src.lcxl3.lib.state._"
local util = require "src.lcxl3.remote.processMidi.util._"
local deb = require "src.lib.debug._"

-- handles changes of the faders of the control surface (Launch Control)
return function(event)
  local processed = false
  for _, control in ipairs(ctrl.faders) do
    processed = util.process(
      control,
      event,
      function(controlSurfaceValue, item)
        local displayIsForced = state.isDisplayForced(control)
        local hostValue = state.get(control .. ".hostValue")
        local status = state.get(control .. ".status")
        if status == const.fader.unknown or displayIsForced then
          -- it goes here when the codec has just been loaded and
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
        state.set(control .. ".status", status)

        -- update host (Reason) only if fader is in sync
        if status == const.fader.inSync and not displayIsForced then
          remote.handle_input({
            item = item.index,
            value = controlSurfaceValue,
            time_stamp = event.time_stamp
          })
        end
      end,
      true -- execute callback even when control is moved with shift pressed
    ) or processed
  end
  return processed
end
