local test = require("test.lib._")
local lu = test.luaUnit
local items = require("src.config.items")
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

function TestProcessNavigation:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestProcessNavigation:testPageUpSelectsTheParameterPageWithoutShift()
    receive(items.pageUpButton.midi, 127)
    assertHandledItem("pageUpButton")
end

function TestProcessNavigation:testPageDownSelectsTheParameterPageWithoutShift()
    receive(items.pageDownButton.midi, 127)
    assertHandledItem("pageDownButton")
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

function TestProcessNavigation:testSelectsThePageAgainAfterShiftWasReleased()
    holdShift()
    releaseShift()
    receive(items.pageDownButton.midi, 127)
    assertHandledItem("pageDownButton")
end

function TestProcessNavigation:testDoesNothingWhenPageButtonIsReleased()
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
