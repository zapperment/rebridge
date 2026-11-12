local const = require "src.lppmk3.config.constants"
local controls = require "src.lppmk3.config.controls"
local midi = require "src.lppmk3.lib.midi._"
local launchnik = require "src.lpp.lib.launchnik._"
local processSetupButton = require "src.lppmk3.remote.processMidi.setupButton"

-- What sets the Launchpad Pro [MK3] apart from the [MK2]; the codec and its
-- parts in src/lpp are made from it.
return {
  id = "LPPMK3",
  name = "Novation Launchpad Pro [MK3]",
  const = const,
  controls = controls,
  midi = midi,
  -- the surface's layout reports, which is all its Setup button produces,
  -- arrive on its DAW port
  processOtherPort = function(event)
    if event.port == const.inputPorts.daw then
      processSetupButton(event)
    end
  end,
  prepareForUse = function()
    -- the surface answers with a layout report, which must not count as a
    -- press of its Setup button
    launchnik.state.preparedAt = remote.get_time_ms()
    return {
      -- turn on programmer mode
      midi.makeSysexEvent "0e 01",
    }
  end,
  releaseFromUse = function()
    return {
      -- turn off programmer mode
      midi.makeSysexEvent "0e 00",
    }
  end,
}
