-- Mocks the remote codec API by declaring the global object "remote", which is
-- provided by the remote host when the program is running in production
local MockFunction = require("test.lib.MockFunction")

local functionNames = {"define_auto_inputs", "define_auto_outputs", "define_items", "get_item_mode", "get_item_name",
                       "get_item_name_and_value", "get_item_short_name", "get_item_short_name_and_value",
                       "get_item_shortest_name", "get_item_shortest_name_and_value", "get_item_state",
                       "get_item_text_value", "get_item_value", "get_time_ms", "handle_input", "is_item_enabled",
                       "make_midi", "match_midi", "trace"}

local mockFunctions = {}

remote = {}

-- Dynamically create the mock functions and the delegation methods
for _, functionName in ipairs(functionNames) do
    mockFunctions[functionName] = MockFunction:new()

    remote[functionName] = function(...)
        return mockFunctions[functionName]:call(...)
    end
end

function remote.mock(functionName)
    return mockFunctions[functionName]
end

function remote.clearMocks()
    for _, functionName in ipairs(functionNames) do
        remote.mock(functionName):clear()
    end
end

-- adding a mock implementation to remote.make_midi that just 
-- returns the input string with the MIDI message hex code
remote.mock("make_midi"):impl(function(midi)
    return midi
end)
