local const = require "src.lpmk2.config.constants"
local controls = require "src.lpcommon.config.sixteenButtonControlsWithoutLogo"
local commonMidi = require "src.lpcommon.lib.midi._"
local midi = require "src.lpmk2.lib.midi._"

local makeSysexEvent = commonMidi.makeSysexEvent(const.sysexHeader)

-- What sets the Launchpad MK2 apart from the other Launchpads; the codec and
-- its parts in src/lpcommon are made from it. It has the palette of the
-- later Launchpads and the buttons of the Launchpad Mini, has no programmer
-- mode, and numbers the buttons of its top row in its own way.
return {
  id = "LPMK2",
  name = "Novation Launchpad MK2",
  const = const,
  controls = controls,
  midi = midi,
  prepareForUse = function()
    return {
      -- the Session layout, which lib/midi/address.lua counts on
      makeSysexEvent "22 00",
    }
  end,
  releaseFromUse = function()
    return {
      -- every LED off, which also ends flashing and pulsing
      makeSysexEvent "0e 00",
    }
  end,
}
