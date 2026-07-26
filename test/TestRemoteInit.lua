local items = require("src.config.items")
local test = require("test.lib._")
local lu = test.luaUnit

require("src.reason.codecs.novation.LCXL3")

TestRemoteInit = {}

function TestRemoteInit:setUp()
    test.resetState()
    remote.clearMocks()
end

function TestRemoteInit:testDefinesItems()
    remote_init()
    local numberOfCalls = #remote.mock("define_items").calls
    local errorMessage = "expected remote.define_items to have been called once, but it was called " .. numberOfCalls ..
        " times"
    lu.assertEquals(numberOfCalls, 1, errorMessage)
end

function TestRemoteInit:testDefinesAutoInputs()
    remote_init()
    local numberOfCalls = #remote.mock("define_auto_inputs").calls
    local errorMessage = "expected remote.define_auto_inputs to have been called once, but it was called " ..
        numberOfCalls .. " times"
    lu.assertEquals(numberOfCalls, 1, errorMessage)
end

function TestRemoteInit:testDefinesAutoOutputs()
    remote_init()
    local numberOfCalls = #remote.mock("define_auto_outputs").calls
    local errorMessage = "expected remote.define_auto_outputs to not have been called, but it was called " ..
        numberOfCalls .. " times"
    lu.assertEquals(numberOfCalls, 0, errorMessage)
end

function TestRemoteInit:testAddsIndicesToItems()
    remote_init()
    for name, item in pairs(items) do
        local errorMessage = "expected index of remote item '" .. name .. "' to be set, but it is nil"
        lu.assertNotNil(item.index, errorMessage)
    end
end
