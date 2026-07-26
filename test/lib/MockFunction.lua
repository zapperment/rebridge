local str = require("src.lib.string._")
local MockFunction = {}

function MockFunction:new()
    local instance = {
        calls = {},
        fakes = {},
        implementation = nil
    }
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function MockFunction:fake(input, output)
    local key = str.serialise(input)
    self.fakes[key] = output
end

function MockFunction:impl(func)
    self.implementation = func
end

-- invoke the mock function; the arguments provided are
-- stored for later examination; if a fake has been set up
-- for the provided argument, returns the fake data
function MockFunction:call(...)
    local args = {...}
    table.insert(self.calls, args)
    local key = str.serialise(args)
    if self.fakes[key] then
        return self.fakes[key]
    end
    if self.implementation then
        return self.implementation(...)
    end
end

function MockFunction:clear()
    self.calls = {}
end

function MockFunction:reset()
    self:clear()
    self.fakes = {}
    self.implementation = nil
end

return MockFunction
