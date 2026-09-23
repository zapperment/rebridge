local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lib.state._"
local const = require "src.lcxl3.config.constants"
local items = require "src.lcxl3.config.items"
local selections = require "src.lcxl3.config.selections"
local hex = require "src.lib.hex._"
local col = require "src.lcxl3.lib.colour._"
local deliverSelection = require "src.remote.deliverMidi.selection"
local deliverButtons = require "src.remote.deliverMidi.buttons"
local setButtons = require "src.remote.setState.buttons"

require "src.reason.codecs.novation.LCXL3"

TestDeliverSelection = {}

local reportSelection = test.reportSelection

local basslineColour = selections.bassline.colour

-- a selecting device without a configuration in config/selections
local unconfiguredDeviceType = "unconfigured"

local function sysex(payload)
    return const.sysexHeader .. " " .. payload .. " f7"
end

local function colourEvent(colourName, intensity)
    return sysex("01 53 xx " .. col.getColour(colourName, intensity))
end

local function nameEvent(text)
    return sysex("06 xx 00 " .. hex.textToHex(text))
end

local function valueEvent(text)
    return sysex("06 xx 01 " .. hex.textToHex(text))
end

local triggerEvent = sysex "04 xx 7f"

-- the events that show the given two lines on the overlay display
local function overlayEvents(firstLine, secondLine)
    return {
        sysex "04 36 61",
        sysex("06 36 00 " .. hex.textToHex(firstLine)),
        sysex("06 36 01 " .. hex.textToHex(secondLine)),
        sysex "04 36 7f",
    }
end

local function contains(events, event)
    for _, candidate in ipairs(events) do
        if candidate == event then
            return true
        end
    end
    return false
end

-- whether the events contain the given ones in order, without anything in between
local function containsSequence(events, sequence)
    for start = 1, #events - #sequence + 1 do
        local matches = true
        for offset, event in ipairs(sequence) do
            if events[start + offset - 1] ~= event then
                matches = false
                break
            end
        end
        if matches then
            return true
        end
    end
    return false
end

-- the events carry the button in the options, as the "xx" placeholder is only
-- substituted by the host; this collects the controllers an event was sent for
local function targetsOf(event)
    local targets = {}
    for _, call in ipairs(remote.mock "make_midi".calls) do
        if call[1] == event then
            table.insert(targets, call[2].x)
        end
    end
    return targets
end

local function controllersOf(...)
    local controllers = {}
    for _, button in ipairs({ ... }) do
        table.insert(controllers, items[button].controller)
    end
    return controllers
end

local function setDeviceType(deviceType)
    state.set("deviceType", deviceType)
    state.update "deviceType"
end

-- reports the selection and delivers it, so that the next delivery only sends
-- what changes after that
local function establishSelection(selectorValue, optionCount, activeOption)
    reportSelection(selectorValue, optionCount, activeOption)
    deliverSelection()
    remote.clearMocks()
end

function TestDeliverSelection:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
    setDeviceType "bassline"
    -- the device type the selection buttons were last delivered for
    deliverSelection()
    remote.clearMocks()
end

function TestDeliverSelection:testNoEventsOnADeviceWithoutASelection()
    reportSelection(nil, 0, nil)
    local events = deliverSelection()
    lu.assertEquals(#events, 0, "expected no events on a device that is not selecting, but got " .. #events)
end

function TestDeliverSelection:testNoEventsWhenNothingHasChanged()
    establishSelection(2, 8, 3)
    local events = deliverSelection()
    lu.assertEquals(#events, 0, "expected no events when the selection has not changed, but got " .. #events)
end

function TestDeliverSelection:testLightsTheSelectedOptionBrightlyAndTheOthersDimly()
    reportSelection(2, 8, 3)
    deliverSelection()
    lu.assertEquals(targetsOf(colourEvent(basslineColour, 95)), controllersOf "button11",
        "expected only the button of the selected option to be lit brightly")
    lu.assertEquals(targetsOf(colourEvent(basslineColour, 1)),
        controllersOf("button9", "button10", "button12", "button13", "button14", "button15", "button16"),
        "expected the buttons of the other options to be lit dimly")
end

function TestDeliverSelection:testLabelsEachButtonWithItsOption()
    reportSelection(2, 8, 3)
    deliverSelection()
    for option = 1, 8 do
        local button = "button" .. (8 + option)
        lu.assertEquals(targetsOf(nameEvent("Pattern " .. option)), controllersOf(button),
            "expected " .. button .. " to be labelled Pattern " .. option)
    end
end

function TestDeliverSelection:testShowsOnForTheSelectedOptionAndOffForTheOthers()
    reportSelection(2, 8, 3)
    deliverSelection()
    lu.assertEquals(targetsOf(valueEvent "On"), controllersOf "button11",
        "expected the button of the selected option to show On")
    lu.assertEquals(#targetsOf(valueEvent "Off"), 7, "expected the buttons of the other options to show Off")
end

function TestDeliverSelection:testDoesNotBringUpTheDisplayOfAPressedSelectionButton()
    reportSelection(2, 8, 3)
    deliverSelection()
    lu.assertEquals(targetsOf(sysex "04 xx 61"), {},
        "expected the selection buttons not to show their displays by themselves")
    lu.assertEquals(#targetsOf(sysex "04 xx 01"), 8,
        "expected the display of every selection button to be configured without the automatic display")
end

function TestDeliverSelection:testMovesTheBrightLedToTheNewSelection()
    establishSelection(2, 8, 3)
    reportSelection(4, 8, 5)
    deliverSelection()
    lu.assertEquals(targetsOf(colourEvent(basslineColour, 95)), controllersOf "button13",
        "expected the button of the newly selected option to be lit brightly")
    lu.assertEquals(contains(targetsOf(colourEvent(basslineColour, 1)), items.button11.controller), true,
        "expected the button of the previously selected option to be lit dimly")
end

function TestDeliverSelection:testLeavesAllButtonsDimWhileNoOptionIsSelected()
    establishSelection(2, 8, 3)
    reportSelection(-1, 8, 0)
    deliverSelection()
    lu.assertEquals(targetsOf(colourEvent(basslineColour, 95)), {}, "expected no button to be lit brightly")
    lu.assertEquals(#targetsOf(colourEvent(basslineColour, 1)), 8, "expected every selection button to be lit dimly")
end

function TestDeliverSelection:testShowsTheNewSelectionOnTheOverlay()
    establishSelection(2, 8, 3)
    reportSelection(4, 8, 5)
    local events = deliverSelection()
    lu.assertEquals(containsSequence(events, overlayEvents("Pattern Select", "Pattern 5")), true,
        "expected the overlay to show the selector parameter and the newly selected option")
end

function TestDeliverSelection:testShowsNoPatternOnTheOverlayWhenDeselected()
    establishSelection(2, 8, 3)
    reportSelection(-1, 8, 0)
    local events = deliverSelection()
    lu.assertEquals(containsSequence(events, overlayEvents("Pattern Select", "No pattern")), true,
        "expected the overlay to show that no pattern is selected")
end

function TestDeliverSelection:testDoesNotShowTheOverlayWhenTheDeviceBecomesTheTarget()
    reportSelection(2, 8, 3)
    local events = deliverSelection()
    lu.assertEquals(contains(events, sysex "04 36 7f"), false,
        "expected no overlay when a selecting device becomes the target, as nothing has been selected")
end

function TestDeliverSelection:testAsksTheSurfaceForAReplyWhenTheMappingIsOutOfStep()
    reportSelection(2, 8, 1)
    local events = deliverSelection()
    lu.assertEquals(contains(events, "b7 1e 00"), true, "expected the surface mode to be queried")
    events = deliverSelection()
    lu.assertEquals(contains(events, "b7 1e 00"), false, "expected the surface mode to be queried only once")
end

function TestDeliverSelection:testDoesNotAskTheSurfaceWhenTheMappingIsInStep()
    reportSelection(2, 8, 3)
    local events = deliverSelection()
    lu.assertEquals(contains(events, "b7 1e 00"), false, "expected no query while the mapping is in step")
end

function TestDeliverSelection:testTurnsOffTheButtonsBeyondTheOptionCount()
    reportSelection(0, 4, 1)
    deliverSelection()
    lu.assertEquals(targetsOf(colourEvent("black", 0)), controllersOf("button13", "button14", "button15", "button16"),
        "expected the selection buttons without an option to be turned off")
end

function TestDeliverSelection:testUsesTheButtonColoursAndOptionNumbersOnAnUnconfiguredDevice()
    setDeviceType(unconfiguredDeviceType)
    reportSelection(0, 8, 1)
    deliverSelection()
    lu.assertEquals(targetsOf(colourEvent(items.button9.colour, 95)), controllersOf "button9",
        "expected a device without a configured colour to keep the button's own colour")
    lu.assertEquals(targetsOf(nameEvent "1"), controllersOf "button9",
        "expected a device without configured labels to label its options by number")
end

function TestDeliverSelection:testRelabelsTheButtonsWhenAnotherSelectingDeviceBecomesTheTarget()
    establishSelection(0, 8, 1)
    setDeviceType(unconfiguredDeviceType)
    local events = deliverSelection()
    lu.assertEquals(contains(events, nameEvent "1"), true,
        "expected the buttons to be relabelled for the new device")
    lu.assertEquals(contains(events, sysex "04 36 7f"), false,
        "expected no overlay when another selecting device becomes the target")
end

function TestDeliverSelection:testTriggersTheDisplayOfAButtonPressedWithShift()
    establishSelection(0, 8, 1)
    state.forceDisplay "button10"
    deliverSelection()
    lu.assertEquals(targetsOf(triggerEvent), controllersOf "button10",
        "expected the display of the button pressed with Shift to be brought up")
end

-- simulates the host reporting a button as mapped to the given parameter, or
-- as unmapped if no parameter is given
local function reportButton(button, paramName, hostValue)
    remote.mock "get_item_state":impl(function()
        return {
            is_enabled = paramName ~= nil,
            value = hostValue or 0,
            remote_item_name = paramName or "",
            text_value = tostring(hostValue or 0),
        }
    end)
    setButtons({ items[button].index })
end

function TestDeliverSelection:testKeepsTheSelectionButtonsFromTheirParametersWhileSelecting()
    establishSelection(0, 8, 1)
    reportButton "button10"
    local events = deliverButtons()
    lu.assertEquals(targetsOf(colourEvent("black", 0)), {},
        "expected the button delivery not to turn off a selection button, but got " .. #events .. " events")
end

function TestDeliverSelection:testHandsTheButtonsBackToTheirParametersWhenTheSelectionEnds()
    -- button 11 was mapped to a parameter while the selection had it
    reportButton("button11", "Oscillator 3 Keytrack", 127)
    establishSelection(0, 8, 1)
    deliverButtons()
    remote.clearMocks()

    setDeviceType "legend"
    reportSelection(nil, 0, nil)
    deliverSelection()
    deliverButtons()
    lu.assertEquals(targetsOf(colourEvent("yellow", 95)), controllersOf "button11",
        "expected the button mapped to a parameter to show that parameter again")
    lu.assertEquals(targetsOf(colourEvent("black", 0)),
        controllersOf("button9", "button10", "button12", "button13", "button14", "button15", "button16"),
        "expected the buttons without a parameter to be turned off")
end
