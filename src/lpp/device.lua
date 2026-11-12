local const = require "src.lpp.config.constants"
local controls = require "src.lpp.config.controls"
local midi = require "src.lpp.lib.midi._"

-- What sets the Launchpad Pro apart from the [MK3]; the codec and its
-- parts in src/lppcommon are made from it.
return {
  id = "LPP",
  name = "Novation Launchpad Pro",
  const = const,
  controls = controls,
  midi = midi,
  prepareForUse = function()
    return {
      -- standalone mode, rather than Ableton Live mode, and in it the
      -- programmer layout
      midi.makeSysexEvent "21 01",
      midi.makeSysexEvent "2c 03",
    }
  end,
  releaseFromUse = function()
    return {
      -- back to the note layout, which the surface starts with
      midi.makeSysexEvent "2c 00",
    }
  end,
}
