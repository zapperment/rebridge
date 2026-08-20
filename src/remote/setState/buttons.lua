local ctrl = require "src.config.controls"
local const = require "src.config.constants"
local state = require "src.lib.state._"
local util = require "src.remote.setState.util._"

-- handles changes of the buttons of the host (Reason)
return function(hostItems)
  for _, hostItemIndex in ipairs(hostItems) do
    for _, control in ipairs(ctrl.buttons) do
      util.set(
        hostItemIndex,
        control,

        -- callback for enabled host item
        -- handles special case for buttons:
        -- differentiate between toggle and
        -- cycle buttons
        function(param, hostValue)
          if util.isToggle(param) then
            state.set(control .. ".type", const.button.toggle)
            state.set(control .. ".hostValue", hostValue > 0 and true or false)
          else
            state.set(control .. ".type", const.button.cycle)
            state.set(control .. ".hostValue", hostValue)
          end
        end
      )
    end
  end
end
