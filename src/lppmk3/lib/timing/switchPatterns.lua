local state = require "src.lppmk3.lib.state._"
local ctrl = require "src.lppmk3.config.controls"

-- makes every pending pattern play
return function()
  for _, device in ipairs(ctrl.devices) do
    state.set(device .. ".playingValue", state.get(device .. ".hostValue"))
  end
end
