local const = require "src.lppmk3.config.constants"

return function(payload, options)
  return remote.make_midi(const.sysexHeader .. " " .. payload .. " f7", options or {})
end
