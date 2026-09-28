local deb = require "src.lib.debug._"
local ctrl = require "src.lppmk3.config.controls"
local padControllers = require "src.lppmk3.config.padControllers"
local state = require "src.lppmk3.lib.state._"
local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"

-- called regularly by the codec to update the remote surface (Launchpad)
return function()
  local events = {}
  for _, pattern in ipairs(ctrl.patterns) do
    local logMe = true
    local enabled = state.update(pattern .. ".enabled")
    local hostValue, hostValueChanged = state.update(pattern .. ".hostValue")
    if enabled and hostValueChanged then
      if logMe then
        deb.log(
          "[lppmk3.deliverMidi.padColours] " ..
          "pattern=" .. pattern
        )
        deb.log(
          "[lppmk3.deliverMidi.padColours] " ..
          "hostValue=" .. hostValue
        )
      end
      for index, padController in ipairs(padControllers[pattern]) do
        local colour = col.config.off
        if index == hostValue then
          colour = col.config.white.bright
        end
        table.insert(events, midi.makeColourEvent(padController, colour))
      end
    end
  end
  return events
end
