local test = require("test.lib._")
local lu = test.luaUnit
local items = require("src.config.items")
local pages = require("src.lib.state.pages")
local processNavigation = require("src.processMidi.navigation")

require("src.reason.codecs.novation.LCXL3")

TestProcessNavigation = {}

-- Shift is a feature control and reports on channel 7, see the programmer's
-- reference guide
local shiftMidi = "b6 3f xx"

-- simulates the remote surface sending a CC, with the mocked remote.match_midi
-- matching on the pattern string alone
local function receive(pattern, value)
    remote.mock("match_midi"):impl(function(midi)
        if midi == pattern then
            return { x = value }
        end
        return nil
    end)
    return processNavigation({ time_stamp = 0 })
end

local function holdShift()
    receive(shiftMidi, 127)
end

local function releaseShift()
    receive(shiftMidi, 0)
end

local function assertHandledItem(expectedItemName)
    local calls = remote.mock("handle_input").calls
    local errorMessage = "expected the input to be handled once, but it was handled " .. #calls .. " times"
    lu.assertEquals(#calls, 1, errorMessage)
    errorMessage = "expected the input to be handled for the " .. expectedItemName .. " item (index " ..
        items[expectedItemName].index .. "), but it was handled for item index " .. tostring(calls[1][1].item)
    lu.assertEquals(calls[1][1].item, items[expectedItemName].index, errorMessage)
    lu.assertEquals(calls[1][1].value, 1, "expected the input to be handled with value 1")
end

-- gives the target device pageCount pages with the given page active, as the
-- host would have reported it through the page selectors
local function setPages(pageCount, active)
    for i = 1, pageCount do
        pages.enabled[i] = true
        pages.selected[i] = i == active
    end
    pages.count = pageCount
    pages.active = active
end

function TestProcessNavigation:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestProcessNavigation:testPageDownStepsToTheNextPageWithoutShift()
    setPages(4, 2)
    receive(items.pageDownButton.midi, 127)
    assertHandledItem("pageSelect3")
    lu.assertEquals(pages.active, 3, "expected the active page to be recorded as 3")
end

function TestProcessNavigation:testPageUpStepsToThePreviousPageWithoutShift()
    setPages(4, 2)
    receive(items.pageUpButton.midi, 127)
    assertHandledItem("pageSelect1")
    lu.assertEquals(pages.active, 1, "expected the active page to be recorded as 1")
end

function TestProcessNavigation:testDoesNotStepBeyondTheLastPage()
    setPages(4, 4)
    receive(items.pageDownButton.midi, 127)
    local calls = remote.mock("handle_input").calls
    local errorMessage = "expected page down on the last page to do nothing, but handle_input was called " ..
        #calls .. " times"
    lu.assertEquals(#calls, 0, errorMessage)
    lu.assertEquals(pages.active, 4, "expected the active page to stay 4")
end

function TestProcessNavigation:testDoesNotStepBeforeTheFirstPage()
    setPages(4, 1)
    receive(items.pageUpButton.midi, 127)
    local calls = remote.mock("handle_input").calls
    local errorMessage = "expected page up on the first page to do nothing, but handle_input was called " ..
        #calls .. " times"
    lu.assertEquals(#calls, 0, errorMessage)
end

function TestProcessNavigation:testDoesNothingOnADeviceWithoutPages()
    receive(items.pageDownButton.midi, 127)
    local calls = remote.mock("handle_input").calls
    local errorMessage = "expected the page buttons to do nothing on a device without a page group, " ..
        "but handle_input was called " .. #calls .. " times"
    lu.assertEquals(#calls, 0, errorMessage)
end

function TestProcessNavigation:testStepsThroughAllPagesOneByOne()
    setPages(3, 1)
    receive(items.pageDownButton.midi, 127)
    receive(items.pageDownButton.midi, 127)
    local calls = remote.mock("handle_input").calls
    lu.assertEquals(#calls, 2, "expected two page steps to be handled")
    local errorMessage = "expected the second page down to step from page 2 to page 3, even before the host " ..
        "confirmed the first step"
    lu.assertEquals(calls[2][1].item, items.pageSelect3.index, errorMessage)
end

function TestProcessNavigation:testBrowsesToThePreviousPatchWithShiftAndPageUp()
    holdShift()
    receive(items.pageUpButton.midi, 127)
    assertHandledItem("patchUpButton")
end

function TestProcessNavigation:testBrowsesToTheNextPatchWithShiftAndPageDown()
    holdShift()
    receive(items.pageDownButton.midi, 127)
    assertHandledItem("patchDownButton")
end

function TestProcessNavigation:testStepsThePageAgainAfterShiftWasReleased()
    setPages(4, 1)
    holdShift()
    releaseShift()
    receive(items.pageDownButton.midi, 127)
    assertHandledItem("pageSelect2")
end

function TestProcessNavigation:testDoesNothingWhenPageButtonIsReleased()
    setPages(4, 2)
    receive(items.pageUpButton.midi, 0)
    local calls = remote.mock("handle_input").calls
    local errorMessage = "expected releasing the page up button not to handle any input, " ..
        "but handle_input was called " .. #calls .. " times"
    lu.assertEquals(#calls, 0, errorMessage)
end

function TestProcessNavigation:testConsumesPageButtonEvents()
    local processed = receive(items.pageUpButton.midi, 127)
    lu.assertEquals(processed, true, "expected the page button event to be consumed")
end

function TestProcessNavigation:testConsumesShiftEvents()
    local processed = receive(shiftMidi, 127)
    lu.assertEquals(processed, true, "expected the Shift event to be consumed")
end

function TestProcessNavigation:testIgnoresUnrelatedEvents()
    local processed = receive("b0 99 xx", 127)
    lu.assertEquals(processed, false, "expected an unrelated event not to be processed")
end
