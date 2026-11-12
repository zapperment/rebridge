local const = require "src.lpp.config.constants"

return function(payload, options)
  return remote.make_midi(const.sysexHeader .. " " .. payload .. " f7", options or {})
end
