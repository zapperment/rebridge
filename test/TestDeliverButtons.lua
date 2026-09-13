local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lib.state._"
local const = require "src.config.constants"
local items = require "src.config.items"
local hex = require "src.lib.hex._"
local col = require "src.lib.colour._"
local processButtons = require "src.remote.processMidi.buttons"
local deliverButtons = require "src.remote.deliverMidi.buttons"
local setButtons = require "src.remote.setState.buttons"

require "src.reason.codecs.novation.LCXL3"

TestDeliverButtons = {}

local function sysex(payload)
    return const.sysexHeader .. " " .. payload .. " f7"
end

local function nameSysex(text)
    return sysex("06 xx 00 " .. hex.textToHex(text))
end

local function valueSysex(text)
    return sysex("06 xx 01 " .. hex.textToHex(text))
end

local function colourEvent(colourName, intensity)
    return sysex("01 53 xx " .. col.getColour(colourName, intensity))
end

local displayOn = sysex "04 xx 61"
local displayOff = sysex "04 xx 01"

local function contains(events, event)
    for _, candidate in ipairs(events) do
        if candidate == event then
            return true
        end
    end
    return false
end

local function countColourEvents(events)
    local count = 0
    for _, event in ipairs(events) do
        if event:find("01 53 xx", 1, true) then
            count = count + 1
        end
    end
    return count
end

-- the events carry the button in the options, as the "xx" placeholder is only
-- substituted by the host; this collects the targets an event was sent for
local function targetsOf(event)
    local targets = {}
    for _, call in ipairs(remote.mock "make_midi".calls) do
        if call[1] == event then
            table.insert(targets, call[2].x)
        end
    end
    return targets
end

-- simulates the host reporting the button as mapped to the given parameter
local function reportButton(button, paramName, hostValue, textValue)
    remote.mock "get_item_state":impl(function()
        return { is_enabled = true, value = hostValue, remote_item_name = paramName, text_value = textValue }
    end)
    setButtons({ items[button].index })
end

local function enableButton(button)
    reportButton(button, "Mute", 127, "1")
    deliverButtons()
    remote.clearMocks()
end

-- simulates the button on the remote surface (Launch Control) being pressed
-- (127) or released (0)
local function sendButton(button, value)
    remote.mock "match_midi":impl(function(midi)
        return midi == items[button].midi and { x = value } or nil
    end)
    processButtons({ time_stamp = 0 })
end

function TestDeliverButtons:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestDeliverButtons:testNoEventsWhenNothingHasChanged()
    local events = deliverButtons()
    local errorMessage = "expected no events when no button state has changed, but got " .. #events
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverButtons:testShowsDisplayConfigNameAndValueWhenButtonBecomesEnabled()
    reportButton("button1", "Mute", 127, "1")
    local events = deliverButtons()
    local errorMessage = "expected the display to be configured when a button becomes enabled"
    lu.assertEquals(contains(events, displayOn), true, errorMessage)
    errorMessage = "expected the param name to be shown when a button becomes enabled"
    lu.assertEquals(contains(events, nameSysex "Mute"), true, errorMessage)
    errorMessage = "expected the resolved value label to be shown when a button becomes enabled"
    lu.assertEquals(contains(events, valueSysex "On"), true, errorMessage)
end

function TestDeliverButtons:testSuppressesDisplayAndTurnsOffLedWhenButtonBecomesDisabled()
    enableButton "button1"
    state.set("button1.enabled", false)
    local events = deliverButtons()
    local errorMessage = "expected the button's display to be suppressed when it becomes disabled"
    lu.assertEquals(contains(events, displayOff), true, errorMessage)
    errorMessage = "expected the button's LED to be turned off when it becomes disabled"
    lu.assertEquals(contains(events, sysex "01 53 xx 00 00 00"), true, errorMessage)
end

function TestDeliverButtons:testDoesNotResendWhenNothingChangesOnTheNextDelivery()
    enableButton "button1"
    local events = deliverButtons()
    local errorMessage = "expected no events on the next delivery when nothing has changed, but got " .. #events
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverButtons:testDoesNotShowAnythingWhenADisabledButtonIsPressed()
    sendButton("button1", 127)
    local events = deliverButtons()
    local errorMessage = "expected no events when a disabled button is pressed, but got " .. #events .. " events"
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverButtons:testToggleButtonIsBrightWhenOn()
    reportButton("button1", "Mute", 127, "1")
    local events = deliverButtons()
    local errorMessage = "expected a toggle button that is on to have the bright colour"
    lu.assertEquals(contains(events, colourEvent(items.button1.colour, 95)), true, errorMessage)
end

function TestDeliverButtons:testToggleButtonIsDimWhenOff()
    reportButton("button1", "Mute", 0, "0")
    local events = deliverButtons()
    local errorMessage = "expected a toggle button that is off to have the dim colour"
    lu.assertEquals(contains(events, colourEvent(items.button1.colour, 1)), true, errorMessage)
end

function TestDeliverButtons:testCycleButtonIsBrightWhileHeldDownAndDimAfterRelease()
    state.set("deviceType", "subtractor")
    state.update "deviceType"
    reportButton("button13", "Filter Type", 32, "1")
    deliverButtons()
    remote.clearMocks()

    sendButton("button13", 127)
    local events = deliverButtons()
    local errorMessage = "expected the cycle button to be bright while held down"
    lu.assertEquals(contains(events, colourEvent("orange", 95)), true, errorMessage)
    remote.clearMocks()

    sendButton("button13", 0)
    events = deliverButtons()
    errorMessage = "expected the cycle button to be dim after it is released"
    lu.assertEquals(contains(events, colourEvent("orange", 1)), true, errorMessage)
end

function TestDeliverButtons:testHostReportDoesNotOverrideACycleButtonsColourWhileItIsHeld()
    state.set("deviceType", "subtractor")
    state.update "deviceType"
    reportButton("button13", "Filter Type", 32, "1")
    deliverButtons()
    remote.clearMocks()

    -- the button is pressed and the host confirms the parameter's new value in
    -- the same tick
    sendButton("button13", 127)
    reportButton("button13", "Filter Type", 64, "2")
    local events = deliverButtons()
    local errorMessage = "expected only one colour event when the press and the host report coincide, but got " ..
        countColourEvents(events)
    lu.assertEquals(countColourEvents(events), 1, errorMessage)
    errorMessage = "expected the cycle button to stay bright, driven by the press rather than the host report"
    lu.assertEquals(contains(events, colourEvent("orange", 95)), true, errorMessage)
end

-- simulates the host reporting the button as unmapped, as it does when a device
-- without buttons is selected
local function disableButton(button, paramName)
    remote.mock "get_item_state":impl(function()
        return { is_enabled = false, value = 0, remote_item_name = paramName, text_value = "" }
    end)
    setButtons({ items[button].index })
end

function TestDeliverButtons:testLightsTheLedAgainWhenAButtonComesBackIntoUseWithTheSameValue()
    enableButton "button1"
    -- switching to a device without buttons: the host unmaps the button, which
    -- turns its LED off
    disableButton("button1", "")
    deliverButtons()
    remote.clearMocks()

    -- switching back to the device with buttons: same parameter, same value as
    -- before it was unmapped
    reportButton("button1", "Mute", 127, "1")
    local events = deliverButtons()
    local errorMessage = "expected the LED to be lit again when the button comes back into use"
    lu.assertEquals(contains(events, colourEvent(items.button1.colour, 95)), true, errorMessage)
end

function TestDeliverButtons:testLightsTheLedAgainWhenAButtonComesBackIntoUseKeepingItsParamName()
    enableButton "button1"
    -- the host may report the button as disabled without dropping the name of
    -- the parameter it was mapped to
    disableButton("button1", "Mute")
    deliverButtons()
    remote.clearMocks()

    reportButton("button1", "Mute", 127, "1")
    local events = deliverButtons()
    local errorMessage = "expected the LED to be lit again when the button comes back into use"
    lu.assertEquals(contains(events, colourEvent(items.button1.colour, 95)), true, errorMessage)
end

function TestDeliverButtons:testLeavesTheLedDimWhenAButtonThatIsOffComesBackIntoUse()
    reportButton("button1", "Mute", 0, "0")
    deliverButtons()
    remote.clearMocks()
    disableButton("button1", "")
    deliverButtons()
    remote.clearMocks()

    reportButton("button1", "Mute", 0, "0")
    local events = deliverButtons()
    local errorMessage = "expected the LED of a button that is off to be dim when it comes back into use"
    lu.assertEquals(contains(events, colourEvent(items.button1.colour, 1)), true, errorMessage)
end

function TestDeliverButtons:testTriggersTheDisplayOfThePressedButton()
    enableButton "button5"
    sendButton("button5", 127)
    local events = deliverButtons()
    local errorMessage = "expected the display trigger event to target button5's controller (" ..
        items.button5.controller .. ")"
    lu.assertEquals(targetsOf(sysex "04 xx 7f"), { items.button5.controller }, errorMessage)
    lu.assertEquals(contains(events, sysex "04 xx 7f"), true, errorMessage)
end

function TestDeliverButtons:testDoesNotTriggerTheDisplayOnRelease()
    enableButton "button5"
    sendButton("button5", 127)
    deliverButtons()
    remote.clearMocks()
    sendButton("button5", 0)
    local events = deliverButtons()
    local errorMessage = "expected releasing a button not to trigger the display"
    lu.assertEquals(contains(events, sysex "04 xx 7f"), false, errorMessage)
end

-- simulates the host reporting the button as mapped to a parameter of the
-- given device type
local function reportButtonOf(deviceType, button, paramName, hostValue, textValue)
    state.set("deviceType", deviceType)
    state.update "deviceType"
    reportButton(button, paramName, hostValue, textValue)
end

function TestDeliverButtons:testMomentaryButtonIsDimWhenItIsMapped()
    reportButtonOf("bassline", "button6", "Run", 0, "Aus")
    local events = deliverButtons()
    local errorMessage = "expected a newly mapped momentary button to be dim"
    lu.assertEquals(contains(events, colourEvent("red", 1)), true, errorMessage)
    lu.assertEquals(contains(events, valueSysex " "), true, "expected a momentary button to show no value")
end

function TestDeliverButtons:testMomentaryButtonIsBrightWhileHeldDownAndDimAfterRelease()
    reportButtonOf("bassline", "button6", "Run", 0, "Aus")
    deliverButtons()
    remote.clearMocks()

    sendButton("button6", 127)
    local events = deliverButtons()
    lu.assertEquals(contains(events, colourEvent("red", 95)), true,
        "expected the momentary button to be bright while held down")
    remote.clearMocks()

    sendButton("button6", 0)
    events = deliverButtons()
    lu.assertEquals(contains(events, colourEvent("red", 1)), true,
        "expected the momentary button to be dim after it is released")
end

function TestDeliverButtons:testHostReportsLeaveAMomentaryButtonsLedAlone()
    reportButtonOf("bassline", "button6", "Run", 0, "Aus")
    deliverButtons()
    remote.clearMocks()

    -- the host echoes the button going down and up, or a click on the panel
    reportButton("button6", "Run", 127, "An")
    local events = deliverButtons()
    lu.assertEquals(#events, 0, "expected the host reporting the button as down to send nothing, but got " .. #events)
    reportButton("button6", "Run", 0, "Aus")
    events = deliverButtons()
    lu.assertEquals(#events, 0, "expected the host reporting the button as up to send nothing, but got " .. #events)
end
