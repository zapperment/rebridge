local test = require("test.lib._")
local lu = test.luaUnit
local state = require("src.lib.state._")
local const = require("src.config.constants")
local items = require("src.config.items")
local textToHex = require("src.lib.hex.textToHex")
local processButtons = require("src.processMidi.buttons")
local deliverButtons = require("src.deliverMidi.buttons")

require("src.reason.codecs.novation.LCXL3")

TestDeliverButtons = {}

local function sysex(payload)
    return const.sysexHeader .. " " .. payload .. " f7"
end

-- the events that show the given name and value on the overlay display
local function overlaySysex(name, value)
    return {
        sysex("04 36 61"),
        sysex("06 36 00 " .. textToHex(name)),
        sysex("06 36 01 " .. textToHex(value)),
        sysex("04 36 7f"),
    }
end

-- the overlay events are appended after the LED colour events
local function trailingEvents(events, count)
    local trailing = {}
    for i = #events - count + 1, #events do
        table.insert(trailing, events[i])
    end
    return trailing
end

local function enableButton(button)
    state.set(button .. ".enabled", true)
    deliverButtons()
end

-- simulates a press of the button on the remote surface (Launch Control)
local function pressButton(button)
    remote.mock("match_midi"):impl(function(midi)
        return midi == items[button].midi and {} or nil
    end)
    processButtons({ time_stamp = 0 })
end

-- how often the overlay display was filled in, as each one reads the param name
local function overlayCount()
    return #remote.mock("get_item_name").calls
end

local function setTextValue(textValue)
    remote.mock("get_item_text_value"):impl(function()
        return textValue
    end)
end

local function setParamName(paramName)
    remote.mock("get_item_name"):impl(function()
        return paramName
    end)
end

function TestDeliverButtons:setUp()
    test.resetState()
    remote.clearMocks()
    setParamName("Mute")
    setTextValue("1")
    remote_init()
end

function TestDeliverButtons:testNoEventsWhenNothingHasChanged()
    local events = deliverButtons()
    local errorMessage = "expected no events when no button state has changed, but got " .. #events
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverButtons:testShowsParamNameAndValueWhenButtonIsPressed()
    enableButton("button1")
    pressButton("button1")
    local events = deliverButtons()
    local errorMessage = "expected the param name and value to be shown on the overlay display"
    lu.assertEquals(trailingEvents(events, 4), overlaySysex("Mute", "On"), errorMessage)
end

function TestDeliverButtons:testShowsTheValue0AsOff()
    setTextValue("0")
    enableButton("button1")
    pressButton("button1")
    local events = deliverButtons()
    local errorMessage = "expected the text value '0' to be shown as 'Off'"
    lu.assertEquals(trailingEvents(events, 4), overlaySysex("Mute", "Off"), errorMessage)
end

function TestDeliverButtons:testShowsTheDeviceSpecificLabelsForKeyModeOnSubTractor()
    state.set("deviceType", "subtractor")
    state.update("deviceType")
    setParamName("Key Mode")
    setTextValue("0")
    enableButton("button11")
    pressButton("button11")
    local events = deliverButtons()
    local errorMessage = "expected SubTractor's 'Key Mode' to show the value 0 as 'Legato'"
    lu.assertEquals(trailingEvents(events, 4), overlaySysex("Key Mode", "Legato"), errorMessage)

    setTextValue("1")
    pressButton("button11")
    events = deliverButtons()
    errorMessage = "expected SubTractor's 'Key Mode' to show the value 1 as 'Retrig'"
    lu.assertEquals(trailingEvents(events, 4), overlaySysex("Key Mode", "Retrig"), errorMessage)
end

function TestDeliverButtons:testStillShowsOnOffForOtherParamsOnADeviceWithSpecialCases()
    state.set("deviceType", "subtractor")
    state.update("deviceType")
    setParamName("Ring Mod")
    enableButton("button4")
    pressButton("button4")
    local events = deliverButtons()
    local errorMessage = "expected a SubTractor param without its own labels to still show 'On'"
    lu.assertEquals(trailingEvents(events, 4), overlaySysex("Ring Mod", "On"), errorMessage)
end

function TestDeliverButtons:testStillShowsOnOffForTheSameParamNameOnAnotherDevice()
    state.set("deviceType", "combinator")
    state.update("deviceType")
    setParamName("Key Mode")
    enableButton("button11")
    pressButton("button11")
    local events = deliverButtons()
    local errorMessage = "expected 'Key Mode' on a device without its own labels to still show 'On'"
    lu.assertEquals(trailingEvents(events, 4), overlaySysex("Key Mode", "On"), errorMessage)
end

function TestDeliverButtons:testShowsAnyOtherValueAsTheHostReportsIt()
    setTextValue("Sine")
    enableButton("button1")
    pressButton("button1")
    local events = deliverButtons()
    local errorMessage = "expected a text value other than '0' or '1' to be shown unchanged"
    lu.assertEquals(trailingEvents(events, 4), overlaySysex("Mute", "Sine"), errorMessage)
end

function TestDeliverButtons:testUsesTheNameAndValueOfThePressedButton()
    enableButton("button5")
    pressButton("button5")
    deliverButtons()
    local nameCalls = remote.mock("get_item_name").calls
    local errorMessage = "expected the param name to be read for button5 (item index " ..
        items.button5.index .. "), but it was read for item index " .. tostring(nameCalls[#nameCalls][1])
    lu.assertEquals(nameCalls[#nameCalls][1], items.button5.index, errorMessage)
end

function TestDeliverButtons:testDoesNotShowParamNameWhenHostChangesTheValue()
    enableButton("button1")
    -- the host (Reason) reporting a new value, e.g. the user clicked the
    -- device's button in the rack on screen
    state.set("button1.value", true)
    deliverButtons()
    local errorMessage = "expected no overlay display when the host changes the value, " ..
        "but the overlay was shown " .. overlayCount() .. " times"
    lu.assertEquals(overlayCount(), 0, errorMessage)
end

function TestDeliverButtons:testDoesNotShowParamNameWhenButtonOnlyBecomesEnabled()
    state.set("button1.enabled", true)
    deliverButtons()
    local errorMessage = "expected no overlay display when a button is merely enabled by the host, " ..
        "but the overlay was shown " .. overlayCount() .. " times"
    lu.assertEquals(overlayCount(), 0, errorMessage)
end

function TestDeliverButtons:testDoesNotShowParamNameWhenDisabledButtonIsPressed()
    pressButton("button1")
    local events = deliverButtons()
    local errorMessage = "expected no events when a disabled button is pressed, but got " .. #events .. " events"
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverButtons:testShowsOnlyTheLastPressedButtonWhenSeveralArePressed()
    enableButton("button1")
    enableButton("button2")
    pressButton("button1")
    pressButton("button2")
    deliverButtons()
    local nameCalls = remote.mock("get_item_name").calls
    local errorMessage = "expected the overlay display to be shown once for the last pressed button, " ..
        "but it was shown " .. #nameCalls .. " times"
    lu.assertEquals(#nameCalls, 1, errorMessage)
    errorMessage = "expected the overlay display to show button2, but it shows item index " ..
        tostring(nameCalls[1][1])
    lu.assertEquals(nameCalls[1][1], items.button2.index, errorMessage)
end

function TestDeliverButtons:testDoesNotShowParamNameAgainOnTheNextDelivery()
    enableButton("button1")
    pressButton("button1")
    deliverButtons()
    local events = deliverButtons()
    local errorMessage = "expected the overlay display not to be repeated on the next delivery, but got " ..
        #events .. " events"
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverButtons:testStillSendsColourWhenButtonIsPressed()
    enableButton("button1")
    pressButton("button1")
    local events = deliverButtons()
    local errorMessage = "expected the button's LED colour to still be sent along with the overlay display events"
    lu.assertEquals(#events, 5, errorMessage)
    lu.assertStrContains(events[1], "01 53 xx", false, errorMessage)
end

function TestDeliverButtons:testTurnsOffLedWhenButtonIsDisabled()
    enableButton("button1")
    state.set("button1.enabled", false)
    local events = deliverButtons()
    local errorMessage = "expected the button's LED to be turned off when the button is disabled"
    lu.assertEquals(events[1], sysex("01 53 xx 00 00 00"), errorMessage)
end
