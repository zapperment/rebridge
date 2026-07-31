local const = require("src.config.constants")

-- if "allow" is non-empty, only messages matching one of its entries pass;
-- "deny" always wins over "allow"
local allow = {
}

local deny = {
  --"lib.valueLabels"
  "getConditionalLabel",
  "getLabel"
}

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
  if #allow > 0 and not matchesAny(message, allow) then
    return
  end
  if matchesAny(message, deny) then
    return
  end
  -- reduce log noise by eliminating duplicates
  if message == previousMessage then
    return
  end
  previousMessage = message
  table.insert(logMessages, message)
  -- if the codec is not running in debug mode, the logs are never dumped
  -- we need to limit the number of log messages to prevent memory leaks
  if #logMessages > const.maxLogMessages then
    table.remove(logMessages, 1)
  end
end
