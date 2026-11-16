local const = require "src.lpm.config.constants"
local controls = require "src.lpm.config.controls"
local midi = require "src.lpm.lib.midi._"

-- What sets the Launchpad Mini apart from the other Launchpads; the
-- codec and its parts in src/lpcommon are made from it. It is programmed as
-- the first Launchpad was: without system exclusive messages, with its own
-- numbering of the pads and buttons, and with LEDs that are red, green or
-- both.
return {
  id = "LPM",
  name = "Novation Launchpad Mini",
  const = const,
  controls = controls,
  midi = midi,
  prepareForUse = function()
    return {
      -- reset: every LED off and the X-Y layout, which lib/midi/address.lua
      -- counts on
      remote.make_midi "B0 00 00",
      -- show the two copies of the LEDs in turn, at the surface's own speed,
      -- so that lights can flash (see lib/midi/makeColourEvent.lua)
      remote.make_midi "B0 00 28",
    }
  end,
  releaseFromUse = function()
    return {
      -- reset: every LED off and no flashing
      remote.make_midi "B0 00 00",
    }
  end,
}
