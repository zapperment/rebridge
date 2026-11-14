local controls = require "src.lpcommon.config.sixteenButtonControls"
local midi = require "src.lpcommon.lib.midi._"

-- Makes the device (see src/lppmk3/device.lua) of a Launchpad with sixteen
-- buttons around its pads, the Launchpad Mini [MK3] or the Launchpad X, from
-- its id, its name and its constants. Those surfaces differ only in the
-- header of their system exclusive messages and in the captions of three
-- buttons: they have the same controls (see
-- config/sixteenButtonControls.lua), take colours the same way and are
-- switched to programmer mode by the same message.
return function(description)
  local makeSysexEvent = midi.makeSysexEvent(description.const.sysexHeader)
  return {
    id = description.id,
    name = description.name,
    const = description.const,
    controls = controls,
    midi = {
      makeSysexEvent = makeSysexEvent,
      makeColourEvent = midi.makeChannelColourEvent,
    },
    prepareForUse = function()
      return {
        -- turn on programmer mode
        makeSysexEvent "0e 01",
      }
    end,
    releaseFromUse = function()
      return {
        -- turn off programmer mode
        makeSysexEvent "0e 00",
      }
    end,
  }
end
