local const = require "src.lppmk3.config.constants"
local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"
local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"

-- called regularly by the codec to update the play button LED: dim and static
-- while the transport is stopped, bright and pulsing while it is playing; it
-- only reads the transport state, which the pad colours then mark as delivered
-- (see remote/deliverMidi/padColours), so it has to be called before them
return function()
  if not state.hasChanged "transport.playing" then
    return {}
  end
  if state.get "transport.playing" then
    return {
      midi.makeColourEvent(items.playButton.controller, col.config.green.vibrant, const.colourBehaviour.pulsing),
    }
  end
  return { midi.makeColourEvent(items.playButton.controller, col.config.green.dim) }
end
