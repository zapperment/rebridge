local const = require("src.config.constants")

return function(payload, options)
  return remote.make_midi(const.sysexHeader .. " " .. payload .. " f7", options or {})
end
