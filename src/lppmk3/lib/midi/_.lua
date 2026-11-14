local const = require "src.lppmk3.config.constants"
local midi = require "src.lpcommon.lib.midi._"

return {
  makeSysexEvent = midi.makeSysexEvent(const.sysexHeader),
  makeColourEvent = midi.makeChannelColourEvent,
}
