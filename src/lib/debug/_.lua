local concatenateKeys = require("src.lib.debug.concatenateKeys")
local midiEventToString = require("src.lib.debug.midiEventToString")
local logWithLogMessages = require("src.lib.debug.log")
local dumpWithLogMessages = require("src.lib.debug.dump")

local logMessages = {}

local function log(message)
  logWithLogMessages(logMessages, message)
end

local function dump()
  local events = dumpWithLogMessages(logMessages)
  logMessages = {}
  return events
end

return {
  concatenateKeys = concatenateKeys,
  midiEventToString = midiEventToString,
  log = log,
  dump = dump
}
