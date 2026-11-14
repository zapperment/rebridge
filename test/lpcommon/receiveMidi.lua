local const = require "src.lpcommon.config.constants"

-- simulates the surface sending a MIDI message of three bytes to the handler
-- given (see src/lpcommon/remote/processMidi/surface.lua), on the port of the
-- surface unless another is given, with the mocked remote.match_midi taking
-- the message apart as the pattern "xx yy zz" does
return function(processSurface, status, data1, data2, port)
  remote.mock "match_midi":impl(function(midi)
    if midi == "xx yy zz" then
      return { x = status, y = data1, z = data2 }
    end
    return nil
  end)
  return processSurface({ time_stamp = 0, port = port or const.ports.surface })
end
