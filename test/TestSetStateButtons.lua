local test = require("test.lib._")
local lu = test.luaUnit
local state = require("src.lib.state._")
local const = require("src.config.constants")
local items = require("src.config.items")
local setButtons = require("src.remote.setState.buttons")

require("src.reason.codecs.novation.LCXL3")

TestSetStateButtons = {}

local function setDeviceType(deviceType)
    state.set("deviceType", deviceType)
    state.update("deviceType")
end

-- simulates the host reporting the given button as mapped to a parameter
local function reportButton(button, paramName, hostValue, textValue)
    remote.mock("get_item_state"):impl(function()
        return { is_enabled = true, value = hostValue, remote_item_name = paramName, text_value = textValue }
    end)
    setButtons({ items[button].index })
end

function TestSetStateButtons:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestSetStateButtons:testRecordsEnabledParamAndHostValueWhenTheHostMapsAButton()
    reportButton("button1", "Mute", 127, "1")
    lu.assertEquals(state.getNext("button1.enabled"), true, "expected the button to become enabled")
    lu.assertEquals(state.getNext("button1.param"), "Mute", "expected the mapped param name to be recorded")
    lu.assertEquals(state.getNext("button1.hostValue"), true, "expected a toggle's host value to be recorded as a boolean")
end

function TestSetStateButtons:testDisablesTheButtonWhenTheHostReportsItUnmapped()
    reportButton("button1", "Mute", 127, "1")
    remote.mock("get_item_state"):impl(function()
        return { is_enabled = false }
    end)
    setButtons({ items.button1.index })
    lu.assertEquals(state.getNext("button1.enabled"), false, "expected the button to become disabled")
end

function TestSetStateButtons:testMarksACycleParamAsTheCycleType()
    setDeviceType("subtractor")
    reportButton("button13", "Filter Type", 32, "1")
    lu.assertEquals(state.getNext("button13.type"), const.button.cycle,
        "expected a parameter configured in cycleParams to mark the button as a cycle type")
end

function TestSetStateButtons:testMarksAnOrdinaryParamAsTheToggleType()
    setDeviceType("subtractor")
    reportButton("button1", "Ring Mod", 127, "1")
    lu.assertEquals(state.getNext("button1.type"), const.button.toggle,
        "expected a parameter not configured in cycleParams to mark the button as a toggle type")
end

function TestSetStateButtons:testShowsTheValue0AsOff()
    reportButton("button1", "Mute", 0, "0")
    lu.assertEquals(state.getNext("button1.hostTextValue"), "Off", "expected the text value '0' to be shown as 'Off'")
end

function TestSetStateButtons:testShowsTheValue1AsOn()
    reportButton("button1", "Mute", 127, "1")
    lu.assertEquals(state.getNext("button1.hostTextValue"), "On", "expected the text value '1' to be shown as 'On'")
end

function TestSetStateButtons:testShowsTheDeviceSpecificLabelsForKeyModeOnSubTractor()
    setDeviceType("subtractor")
    reportButton("button11", "Key Mode", 0, "0")
    lu.assertEquals(state.getNext("button11.hostTextValue"), "Legato",
        "expected SubTractor's 'Key Mode' to show the value 0 as 'Legato'")

    reportButton("button11", "Key Mode", 127, "1")
    lu.assertEquals(state.getNext("button11.hostTextValue"), "Retrig",
        "expected SubTractor's 'Key Mode' to show the value 1 as 'Retrig'")
end

function TestSetStateButtons:testStillShowsOnOffForOtherParamsOnADeviceWithSpecialCases()
    setDeviceType("subtractor")
    reportButton("button4", "Ring Mod", 127, "1")
    lu.assertEquals(state.getNext("button4.hostTextValue"), "On",
        "expected a SubTractor param without its own labels to still show 'On'")
end

function TestSetStateButtons:testShowsTheLabelOfACycleParamValue()
    setDeviceType("subtractor")
    reportButton("button4", "LFO2 Dest", 64, "2")
    lu.assertEquals(state.getNext("button4.hostTextValue"), "F.Freq 2",
        "expected LFO2 Dest's value 2 to be shown with its label from the SubTractor UI")
end

function TestSetStateButtons:testShowsThePlainValueForAnUnlabelledCycleParamValue()
    -- every value a SubTractor cycle parameter can actually take has a label
    -- configured; this pins down the fallback for a value that has none,
    -- rather than the On/Off defaults
    setDeviceType("subtractor")
    reportButton("button1", "Osc1 Phase Mode", 100, "9")
    lu.assertEquals(state.getNext("button1.hostTextValue"), "9",
        "expected a cycling parameter's unlabelled value to be shown plainly, not 'On'")
end

function TestSetStateButtons:testStillShowsOnOffForTheSameParamNameOnAnotherDevice()
    setDeviceType("combinator")
    reportButton("button11", "Key Mode", 127, "1")
    lu.assertEquals(state.getNext("button11.hostTextValue"), "On",
        "expected 'Key Mode' on a device without its own labels to still show 'On'")
end

function TestSetStateButtons:testShowsAnyOtherValueAsTheHostReportsIt()
    reportButton("button1", "Mute", 64, "Sine")
    lu.assertEquals(state.getNext("button1.hostTextValue"), "Sine",
        "expected a text value other than '0' or '1' to be shown unchanged")
end
