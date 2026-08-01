local config = require("src.lib.debug.config")

local previousMessage = nil

local function matchesAny(message, list)
  for _, needle in ipairs(list) do
    if string.find(message, needle, 1, true) then
      return true
    end
  end
  return false
end

return function(logMessages, message)
  if #config.allow > 0 and not matchesAny(message, config.allow) then
    return
  end
  if matchesAny(message, config.deny) then
    return
  end
  --reduce log noise by eliminating duplicates
  if message == previousMessage then
    table.insert(logMessages, config.repeatSignal)
    return
  end
  previousMessage = message
  table.insert(logMessages, message)
  -- if the codec is not running in debug mode, the logs are never dumped
  -- we need to limit the number of log messages to prevent memory leaks
  if #logMessages > config.maxLogMessages then
    table.remove(logMessages, 1)
  end
end
