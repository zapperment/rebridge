local const = require("src.config.constants")
local state = require("src.lib.state._")
local util = require("src.remote.setState.util._")
local deb = require("src.lib.debug._")

-- handles changes of the faders of the host (Reason)
return function(hostItems)
  for _, hostItemIndex in ipairs(hostItems) do
    for i = 1, const.counts.faders do
      local control = "fader" .. i
      util.set(
        hostItemIndex,
        control,

        -- callback for enabled host item
        -- handles special case for faders:
        -- set pickup state
        function(_, hostValue)
          local status
          local controlSurfaceValue = state.get(control .. ".controlSurfaceValue")
          if controlSurfaceValue == nil then
            -- it goes here when the codec is loaded
            -- because we do not know where the fader is at on the control surface
            status = const.fader.unknown
          elseif hostValue >= controlSurfaceValue - const.pickupTolerance and hostValue <= controlSurfaceValue + const.pickupTolerance then
            status = const.fader.inSync
          elseif hostValue > controlSurfaceValue then
            status = const.fader.tooLow
          elseif hostValue < controlSurfaceValue then
            status = const.fader.tooHigh
          end
          state.set(control .. ".status", status)
        end,

        -- callback for disabled host item
        function()
          state.set(control .. ".status", const.fader.unassigned)
        end
      )
    end
  end
end
