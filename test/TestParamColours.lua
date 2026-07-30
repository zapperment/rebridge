local test = require("test.lib._")
local lu = test.luaUnit
local state = require("src.lib.state._")
local items = require("src.config.items")
local getColour = require("src.lib.colour.getColour")
local getColourName = require("src.lib.colour.getColourName")
local setEncoders = require("src.setState.encoders")
local setButtons = require("src.setState.buttons")

require("src.reason.codecs.novation.LCXL3")

TestParamColours = {}

local function setDeviceType(deviceType)
    state.set("deviceType", deviceType)
    state.update("deviceType")
end

-- simulates the host reporting a parameter mapped to the given control
local function reportItem(itemName, paramName, value)
    remote.mock("get_item_state"):impl(function()
        return { is_enabled = true, value = value, remote_item_name = paramName }
    end)
    if itemName:find("encoder") then
        setEncoders({ items[itemName].index })
    else
        setButtons({ items[itemName].index })
    end
    return state.getNext(itemName .. ".colour")
end

function TestParamColours:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestParamColours:testGivesAnEncoderTheColourOfItsParamGroup()
    setDeviceType("subtractor")
    -- encoder1's own colour is red, but Filter Freq belongs to the filter 1
    -- group, so the two must not be confused here
    local colour = reportItem("encoder1", "Filter Freq", 100)
    local errorMessage = "expected an encoder mapped to Filter Freq to take the filter 1 group's colour"
    lu.assertEquals(colour, getColour("orange", 100), errorMessage)
end

function TestParamColours:testGivesAButtonTheColourOfItsParamGroup()
    setDeviceType("subtractor")
    local colour = reportItem("button1", "Noise On/Off", 127)
    local errorMessage = "expected a button mapped to Noise On/Off to take the noise group's colour"
    lu.assertEquals(colour, getColour("green", 95), errorMessage)
end

function TestParamColours:testGivesTheWholeGroupTheSameColour()
    setDeviceType("subtractor")
    local expected = getColour("yellow", 100)
    for _, paramName in ipairs({ "Osc2 Wave", "Osc2 Octave", "Osc2 Semitone", "Osc2 Fine Tune" }) do
        local colour = reportItem("encoder5", paramName, 100)
        local errorMessage = "expected " .. paramName .. " to take the oscillator 2 group's colour"
        lu.assertEquals(colour, expected, errorMessage)
    end
end

function TestParamColours:testKeepsTheControlsOwnColourOnADeviceWithoutParamColours()
    setDeviceType("combinator")
    local colour = reportItem("encoder1", "Rotary 1", 100)
    local errorMessage = "expected a Combinator's controls to keep their own colours"
    lu.assertEquals(colour, getColour(items.encoder1.colour, 100), errorMessage)
end

function TestParamColours:testKeepsTheControlsOwnColourForAnUnlistedParam()
    setDeviceType("subtractor")
    local colour = reportItem("encoder1", "Master Level", 100)
    local errorMessage = "expected a parameter without a colour of its own to keep the control's colour"
    lu.assertEquals(colour, getColour(items.encoder1.colour, 100), errorMessage)
end

function TestParamColours:testResolvesTheColourNameForAKnownParam()
    local errorMessage = "expected LFO1 Rate to resolve to the LFO 1 group's colour"
    lu.assertEquals(getColourName("subtractor", "LFO1 Rate", "red"), "violet", errorMessage)
end

function TestParamColours:testFallsBackToTheGivenColourName()
    lu.assertEquals(getColourName("subtractor", "Master Level", "white"), "white",
        "expected an unlisted parameter to fall back to the control's colour")
    lu.assertEquals(getColourName("combinator", "Rotary 1", "white"), "white",
        "expected a device type without param colours to fall back to the control's colour")
end
