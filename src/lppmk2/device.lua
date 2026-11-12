local const = require "src.lppmk2.config.constants"
local controls = require "src.lppmk2.config.controls"
local midi = require "src.lppmk2.lib.midi._"

-- What sets the Launchpad Pro [MK2] apart from the [MK3]; the codec and its
-- parts in src/lpp are made from it.
return {
  id = "LPPMK2",
  name = "Novation Launchpad Pro [MK2]",
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
