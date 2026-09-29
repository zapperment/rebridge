local ctrl = require "src.lppmk3.config.controls"
local padControllers = require "src.lppmk3.config.padControllers"
local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"

-- the events that turn off every pattern pad; the Launchpad keeps its pads lit
-- for as long as it is powered, so without them, the pads the last session left
-- lit would stay lit, although no LaunchEon lights them
return function()
  local events = {}
  for _, device in ipairs(ctrl.devices) do
    for _, padController in ipairs(padControllers[device]) do
      table.insert(events, midi.makeColourEvent(padController, col.config.off))
    end
  end
  return events
end
