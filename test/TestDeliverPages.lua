local test = require("test.lib._")
local lu = test.luaUnit
local state = require("src.lib.state._")
local const = require("src.config.constants")
local textToHex = require("src.lib.hex.textToHex")
local pages = require("src.lib.state.pages")
local deliverPages = require("src.deliverMidi.pages")

require("src.reason.codecs.novation.LCXL3")

TestDeliverPages = {}

local function sysex(payload)
    return const.sysexHeader .. " " .. payload .. " f7"
end

-- the events that show the given two lines on the overlay display
local function overlaySysex(firstLine, secondLine)
    return {
        sysex("04 36 61"),
        sysex("06 36 00 " .. textToHex(firstLine)),
        sysex("06 36 01 " .. textToHex(secondLine)),
        sysex("04 36 7f"),
    }
end

-- gives the target device pageCount pages, as the host would have reported
-- them through the page selectors
local function givePages(pageCount)
    for i = 1, pageCount do
        pages.enabled[i] = true
    end
    pages.count = pageCount
end

function TestDeliverPages:setUp()
    test.resetState()
    remote.clearMocks()
    state.set("deviceType", "subtractor")
    state.update("deviceType")
    remote_init()
    givePages(4)
end

function TestDeliverPages:testNoEventsWhenThePageHasNotChanged()
    local events = deliverPages()
    local errorMessage = "expected no events when the page has not changed, but got " .. #events
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverPages:testShowsThePageNumberAndNameOnASwitch()
    pages.setActive(3)
    local events = deliverPages()
    local errorMessage = "expected the number and name of the newly selected page to be shown"
    lu.assertEquals(events, overlaySysex("Page 3", "LFO"), errorMessage)
end

function TestDeliverPages:testShowsTheNameOfEveryPage()
    local expectedNames = { "Osc & Noise", "Filter & Amp", "LFO", "Perf & Mod" }
    for page, expectedName in ipairs(expectedNames) do
        pages.active = page == 1 and 2 or 1 -- make sure the page really changes
        pages.setActive(page)
        local events = deliverPages()
        local errorMessage = "expected page " .. page .. " to be shown as '" .. expectedName .. "'"
        lu.assertEquals(events, overlaySysex("Page " .. page, expectedName), errorMessage)
    end
end

function TestDeliverPages:testShowsThePageOnlyOnce()
    pages.setActive(2)
    deliverPages()
    local events = deliverPages()
    local errorMessage = "expected the page display not to be repeated on the next delivery, but got " ..
        #events .. " events"
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverPages:testDoesNotShowThePageWhenItStaysTheSame()
    pages.setActive(1)
    local events = deliverPages()
    local errorMessage = "expected no events when the page is set to the one already active, but got " ..
        #events .. " events"
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverPages:testDoesNotShowAPageOnADeviceWithoutPages()
    -- switching away from a device with pages to one without, e.g. a
    -- Combinator, falls back to page 1 without the device having any pages
    pages.count = 0
    pages.setActive(1)
    local events = deliverPages()
    local errorMessage = "expected no page display on a device without pages, but got " .. #events .. " events"
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverPages:testShowsOnlyTheNumberForAPageWithoutAName()
    -- a device whose pages have no names configured
    state.set("deviceType", "malstrom")
    state.update("deviceType")
    pages.setActive(2)
    local events = deliverPages()
    local errorMessage = "expected a page without a configured name to be shown with its number alone"
    lu.assertEquals(events, overlaySysex("Page 2", " "), errorMessage)
end
