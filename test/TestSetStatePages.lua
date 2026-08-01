local test = require("test.lib._")
local lu = test.luaUnit
local items = require("src.config.items")
local pages = require("src.lib.state.pages")
local setPages = require("src.remote.setState.pages")

require("src.reason.codecs.novation.LCXL3")

TestSetStatePages = {}

-- simulates the host reporting the state of the page selectors: an array of
-- values, one per selector, where a number is an enabled selector's value and
-- false is a disabled selector
local function reportSelectors(selectorValues)
    local states = {}
    local changedItems = {}
    for i, value in ipairs(selectorValues) do
        local index = items["pageSelect" .. i].index
        states[index] = value and { is_enabled = true, value = value } or { is_enabled = false, value = 0 }
        table.insert(changedItems, index)
    end
    remote.mock("get_item_state"):impl(function(index)
        return states[index]
    end)
    setPages(changedItems)
end

function TestSetStatePages:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestSetStatePages:testLearnsThePageCountFromTheEnabledSelectors()
    reportSelectors({ 0, 0, 0, 127, false, false, false, false })
    lu.assertEquals(pages.count, 4, "expected a device with four bound selectors to have four pages")
end

function TestSetStatePages:testLearnsTheActivePageFromTheSelectedSelector()
    reportSelectors({ 0, 0, 0, 127, false, false, false, false })
    lu.assertEquals(pages.active, 4, "expected the selector with a value to mark the active page")
end

function TestSetStatePages:testFollowsAPageSwitchReportedByTheHost()
    reportSelectors({ 127, 0, 0, 0, false, false, false, false })
    reportSelectors({ 0, 0, 127, 0, false, false, false, false })
    lu.assertEquals(pages.active, 3, "expected the active page to follow the host's report")
end

function TestSetStatePages:testHasNoPagesOnADeviceWithoutSelectors()
    reportSelectors({ 127, 0, 0, 0, false, false, false, false })
    reportSelectors({ false, false, false, false, false, false, false, false })
    lu.assertEquals(pages.count, 0, "expected a device without bound selectors to have no pages")
    lu.assertEquals(pages.active, 1, "expected the active page to fall back to 1")
end

function TestSetStatePages:testIgnoresUnrelatedItems()
    reportSelectors({ 0, 127, 0, 0, false, false, false, false })
    remote.mock("get_item_state"):impl(function()
        return { is_enabled = true, value = 64 }
    end)
    setPages({ items.encoder1.index })
    lu.assertEquals(pages.active, 2, "expected changes of unrelated items to leave the pages untouched")
    lu.assertEquals(pages.count, 4, "expected changes of unrelated items to leave the page count untouched")
end
