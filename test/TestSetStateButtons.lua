local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lib.state._"
local const = require "src.config.constants"
local items = require "src.config.items"
local disp = require "src.lib.display._"
local setButtons = require "src.remote.setState.buttons"

require "src.reason.codecs.novation.LCXL3"

TestSetStateButtons = {}

local function setDeviceType(deviceType)
    state.set("deviceType", deviceType)
    state.update "deviceType"
end

-- simulates the host reporting the given button as mapped to a parameter
local function reportButton(button, paramName, hostValue, textValue)
    remote.mock "get_item_state":impl(function()
        return { is_enabled = true, value = hostValue, remote_item_name = paramName, text_value = textValue }
    end)
    setButtons({ items[button].index })
end

-- the state keeps the host's text value as reported; the label that goes to
-- the display is looked up from it when the value is delivered
local function displayValueOf(button)
    return disp.getButtonDisplayValue(button)
end

function TestSetStateButtons:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestSetStateButtons:testRecordsEnabledParamAndHostValueWhenTheHostMapsAButton()
    reportButton("button1", "Mute", 127, "1")
    lu.assertEquals(state.get "button1.enabled", true, "expected the button to become enabled")
    lu.assertEquals(state.get "button1.param", "Mute", "expected the mapped param name to be recorded")
    lu.assertEquals(state.get "button1.hostValue", true, "expected a toggle's host value to be recorded as a boolean")
end

function TestSetStateButtons:testDisablesTheButtonWhenTheHostReportsItUnmapped()
    reportButton("button1", "Mute", 127, "1")
    remote.mock "get_item_state":impl(function()
        return { is_enabled = false }
    end)
    setButtons({ items.button1.index })
    lu.assertEquals(state.get "button1.enabled", false, "expected the button to become disabled")
end

function TestSetStateButtons:testMarksACycleParamAsTheCycleType()
    setDeviceType "subtractor"
    reportButton("button13", "Filter Type", 32, "1")
    lu.assertEquals(state.get "button13.type", const.button.cycle,
        "expected a parameter configured in cycleParams to mark the button as a cycle type")
end

function TestSetStateButtons:testMarksAnOrdinaryParamAsTheToggleType()
    setDeviceType "subtractor"
    reportButton("button1", "Ring Mod", 127, "1")
    lu.assertEquals(state.get "button1.type", const.button.toggle,
        "expected a parameter not configured in cycleParams to mark the button as a toggle type")
end

-- simulates the host reporting the momentary Run button as held down (127)
-- or up (0), as it does after a press on the surface or a click on the panel
local function reportRun(down)
    reportButton("button6", "Run", down and 127 or 0, down and "An" or "Aus")
end

function TestSetStateButtons:testMarksAMomentaryParamAsTheMomentaryType()
    setDeviceType "bassline"
    reportRun(false)
    lu.assertEquals(state.get "button6.type", const.button.momentary,
        "expected a parameter configured in momentaryParams to mark the button as a momentary type")
end

function TestSetStateButtons:testDropsTheHostsReportOfAMomentaryButton()
    setDeviceType "bassline"
    reportRun(false)
    state.updateAll()
    reportRun(true)
    lu.assertEquals(state.hasChanged "button6.hostValue", false,
        "expected the host reporting the button as down to change nothing")
    lu.assertEquals(state.hasChanged "button6.hostTextValue", false,
        "expected the host's text for the button to be dropped")
end

function TestSetStateButtons:testShowsNoValueForAMomentaryParam()
    setDeviceType "bassline"
    reportRun(true)
    lu.assertEquals(displayValueOf "button6", " ", "expected a momentary button to show no value")
end

function TestSetStateButtons:testMarksABankButtonAsTheCycleType()
    setDeviceType "bassline"
    reportButton("button1", "Pattern 5 OffBeat Bank", 127, "B")
    lu.assertEquals(state.get "button1.type", const.button.cycle,
        "expected the two-value Bank parameter to be a cycle button, as configured")
    lu.assertEquals(displayValueOf "button1", "B", "expected the cycle button to show the host's text value")
end

function TestSetStateButtons:testShowsTheValue0AsOff()
    reportButton("button1", "Mute", 0, "0")
    lu.assertEquals(displayValueOf "button1", "Off", "expected the text value '0' to be shown as 'Off'")
end

function TestSetStateButtons:testShowsTheValue1AsOn()
    reportButton("button1", "Mute", 127, "1")
    lu.assertEquals(displayValueOf "button1", "On", "expected the text value '1' to be shown as 'On'")
end

function TestSetStateButtons:testShowsTheDeviceSpecificLabelsForKeyModeOnSubTractor()
    setDeviceType "subtractor"
    reportButton("button11", "Key Mode", 0, "0")
    lu.assertEquals(displayValueOf "button11", "Legato",
        "expected SubTractor's 'Key Mode' to show the value 0 as 'Legato'")

    reportButton("button11", "Key Mode", 127, "1")
    lu.assertEquals(displayValueOf "button11", "Retrig",
        "expected SubTractor's 'Key Mode' to show the value 1 as 'Retrig'")
end

function TestSetStateButtons:testStillShowsOnOffForOtherParamsOnADeviceWithSpecialCases()
    setDeviceType "subtractor"
    reportButton("button4", "Ring Mod", 127, "1")
    lu.assertEquals(displayValueOf "button4", "On",
        "expected a SubTractor param without its own labels to still show 'On'")
end

function TestSetStateButtons:testShowsTheLabelOfACycleParamValue()
    setDeviceType "subtractor"
    reportButton("button4", "LFO2 Dest", 64, "2")
    lu.assertEquals(displayValueOf "button4", "F.Freq 2",
        "expected LFO2 Dest's value 2 to be shown with its label from the SubTractor UI")
end

function TestSetStateButtons:testShowsThePlainValueForAnUnlabelledCycleParamValue()
    -- every value a SubTractor cycle parameter can actually take has a label
    -- configured; this pins down the fallback for a value that has none,
    -- rather than the On/Off defaults
    setDeviceType "subtractor"
    reportButton("button1", "Osc1 Phase Mode", 100, "9")
    lu.assertEquals(displayValueOf "button1", "9",
        "expected a cycling parameter's unlabelled value to be shown plainly, not 'On'")
end

function TestSetStateButtons:testStillShowsOnOffForTheSameParamNameOnAnotherDevice()
    setDeviceType "combinator"
    reportButton("button11", "Key Mode", 127, "1")
    lu.assertEquals(displayValueOf "button11", "On",
        "expected 'Key Mode' on a device without its own labels to still show 'On'")
end

function TestSetStateButtons:testShowsAnyOtherValueAsTheHostReportsIt()
    reportButton("button1", "Mute", 64, "Sine")
    lu.assertEquals(displayValueOf "button1", "Sine",
        "expected a text value other than '0' or '1' to be shown unchanged")
end
