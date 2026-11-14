local const = require "src.lpp.config.constants"
local midi = require "src.lpcommon.lib.midi._"

return midi.makeSysexEvent(const.sysexHeader)
