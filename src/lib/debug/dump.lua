local makeLogEvent = require("src.lib.midi.makeLogEvent")

return function(logMessages)
  local events = {}
  for _, message in pairs(logMessages) do
    table.insert(events, makeLogEvent(message))
  end
  return events
end
