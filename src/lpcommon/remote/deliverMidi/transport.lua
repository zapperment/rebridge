local const = require "src.lpcommon.config.constants"
local state = require "src.lpcommon.lib.state._"
local col = require "src.lpcommon.lib.colour._"
local surface = require "src.lpcommon.lib.surface._"

local pulsing = const.colourBehaviour.pulsing

-- makes what the codec calls regularly to work out the lights (see
-- lib/surface/makeLight.lua) of the play and record buttons of the device
-- given: dim and static while off, bright and pulsing while on; each change
-- is delivered once
return function(device)
  local makeLight = surface.makeLight
  local playButton = device.controls.play
  local recordButton = device.controls.record

  return function()
    local events = {}

    if state.hasChanged "transport.playing" then
      local playing = state.update "transport.playing"
      local colour = playing and col.config.green.vibrant or col.config.green.dim
      local behaviour = playing and pulsing or nil
      table.insert(events, makeLight(playButton, colour, behaviour))
    end

    if state.hasChanged "transport.recording" then
      local recording = state.update "transport.recording"
      local colour = recording and col.config.red.vibrant or col.config.red.dim
      local behaviour = recording and pulsing or nil
      table.insert(events, makeLight(recordButton, colour, behaviour))
    end

    return events
  end
end
