local ctrl = require "src.lcxl3.config.controls"
local const = require "src.lcxl3.config.constants"
local state = require "src.lcxl3.lib.state._"
local util = require "src.remote.setState.util._"

-- handles changes of the buttons of the host (Reason)
return function(hostItems)
  for _, hostItemIndex in ipairs(hostItems) do
    for _, control in ipairs(ctrl.buttons) do
      util.set(
        hostItemIndex,
        control,

        -- callback for enabled host item: a cycle button keeps the host's
        -- value as reported, to step on from it; a toggle only needs to know
        -- whether its parameter is on or off
        function(param, hostValue)
          local buttonType = util.getButtonType(param)
          state.set(control .. ".type", buttonType)
          if buttonType == const.button.cycle then
            state.set(control .. ".hostValue", hostValue)
          elseif buttonType == const.button.momentary then
            -- the host only says whether the button is held down, which the
            -- surface knows better than the host, so the report is dropped:
            -- nothing changes for the delivery to react to
            -- (see config/momentaryParams)
            state.set(control .. ".hostValue", false)
            state.set(control .. ".hostTextValue", "")
          else
            state.set(control .. ".hostValue", hostValue > 0 and true or false)
          end
        end
      )
    end
  end
end
