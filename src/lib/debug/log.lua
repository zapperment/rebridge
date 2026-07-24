local const = require("src.config.constants")

return function(logMessages, message)
  table.insert(logMessages, message)
  -- if the codec is not running in debug mode, the logs are never dumped
  -- we need to limit the number of log messages to prevent memory leaks
  if #logMessages > const.maxLogMessages then
    table.remove(logMessages, 1)
  end
end
