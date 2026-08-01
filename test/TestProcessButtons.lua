local test = require("test.lib._")
local lu = test.luaUnit
local state = require("src.lib.state._")
local items = require("src.config.items")
local buttonStates = require("src.lib.state.buttons")
local getColour = require("src.lib.colour.getColour")
local processButtons = require("src.processMidi.buttons")
local setButtons = require("src.remote.setState.buttons")

require("src.reason.codecs.novation.LCXL3")

TestProcessButtons = {}

local function setDeviceType(deviceType)
    state.set("deviceType", deviceType)
    state.update("deviceType")
end

local function setParamName(paramName)
    remote.mock("get_item_name"):impl(function()
        return paramName
    end)
end

-- the value the host reports for the item, scaled to the item's 0-127 range
local function setHostValue(scaledValue)
    remote.mock("get_item_state"):impl(function()
        return { value = scaledValue }
    end)
end

local function enableButton(button)
    state.set(button .. ".enabled", true)
    state.update(button .. ".enabled")
end

-- simulates the hardware button being pressed (127) or released (0)
local function sendButton(button, value)
    remote.mock("match_midi"):impl(function(midi)
        return midi == items[button].midi and { x = value } or nil
    end)
    processButtons({ time_stamp = 0 })
end

local function handledValues()
    local values = {}
    for _, call in ipairs(remote.mock("handle_input").calls) do
        table.insert(values, call[1].value)
    end
    return values
end

function TestProcessButtons:setUp()
    test.resetState()
    remote.clearMocks()
    setDeviceType("subtractor")
    setParamName("Filter Type")
    setHostValue(0)
    remote_init()
    enableButton("button13")
end

function TestProcessButtons:testCyclesToTheNextValueOnPress()
    -- Filter Type has 5 values; the host is at value 1, reported as 32 scaled
    setHostValue(32)
    sendButton("button13", 127)
    local errorMessage = "expected the press to advance Filter Type from value 1 to 2 (scaled 64), but " ..
        "the handled values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 64 }, errorMessage)
end

function TestProcessButtons:testWrapsAroundToTheFirstValue()
    -- the host is at Filter Type's last value 4, reported as 127 scaled
    setHostValue(127)
    sendButton("button13", 127)
    local errorMessage = "expected the press to wrap Filter Type around from its last value to 0, but " ..
        "the handled values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 0 }, errorMessage)
end

function TestProcessButtons:testIsBrightWhileHeldDown()
    sendButton("button13", 127)
    local errorMessage = "expected the cycle button to have the bright colour while held down"
    lu.assertEquals(state.getNext("button13.colour"), getColour("orange", 95), errorMessage)
    lu.assertEquals(buttonStates.held.button13, true, "expected the button to be recorded as held")
end

function TestProcessButtons:testIsDimAfterRelease()
    sendButton("button13", 127)
    sendButton("button13", 0)
    local errorMessage = "expected the cycle button to have the dim colour after it is released"
    lu.assertEquals(state.getNext("button13.colour"), getColour("orange", 1), errorMessage)
    lu.assertEquals(buttonStates.held.button13, nil, "expected the button to no longer be recorded as held")
end

function TestProcessButtons:testReleaseDoesNotChangeTheHostValue()
    sendButton("button13", 127)
    sendButton("button13", 0)
    local numberOfCalls = #remote.mock("handle_input").calls
    local errorMessage = "expected only the press to update the host, but handle_input was called " ..
        numberOfCalls .. " times"
    lu.assertEquals(numberOfCalls, 1, errorMessage)
end

function TestProcessButtons:testTwoValueParamsStillToggle()
    setParamName("Ring Mod")
    sendButton("button13", 127)
    local errorMessage = "expected a two-value parameter to toggle on (127), but the handled values are " ..
        table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 127 }, errorMessage)
    lu.assertEquals(state.getNext("button13.value"), true, "expected the toggle value to flip on")
end

function TestProcessButtons:testTogglesIgnoreTheRelease()
    setParamName("Ring Mod")
    sendButton("button13", 127)
    sendButton("button13", 0)
    local numberOfCalls = #remote.mock("handle_input").calls
    local errorMessage = "expected the toggle's release to be ignored, but handle_input was called " ..
        numberOfCalls .. " times"
    lu.assertEquals(numberOfCalls, 1, errorMessage)
    lu.assertEquals(state.getNext("button13.value"), true, "expected the toggle value to still be on")
end

function TestProcessButtons:testCycleParamsAreScopedToTheirDeviceType()
    -- the Combinator defines no cycle parameters, so even a parameter named
    -- like one behaves as a toggle there
    setDeviceType("combinator")
    sendButton("button13", 127)
    local errorMessage = "expected the parameter to toggle on a device type without cycle parameters, " ..
        "but the handled values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 127 }, errorMessage)
end

function TestProcessButtons:testHostChangesKeepCycleButtonsDim()
    remote.mock("get_item_state"):impl(function()
        return { is_enabled = true, value = 64, remote_item_name = "Filter Type" }
    end)
    setButtons({ items.button13.index })
    local errorMessage = "expected a cycle button to stay dim when the host reports a non-zero value"
    lu.assertEquals(state.getNext("button13.colour"), getColour("orange", 1), errorMessage)
end

function TestProcessButtons:testHostChangesDoNotDimACycleButtonWhileItIsHeld()
    sendButton("button13", 127)
    remote.mock("get_item_state"):impl(function()
        return { is_enabled = true, value = 64, remote_item_name = "Filter Type" }
    end)
    setButtons({ items.button13.index })
    local errorMessage = "expected the cycle button to stay bright while held down, even when the host " ..
        "reports the new value"
    lu.assertEquals(state.getNext("button13.colour"), getColour("orange", 95), errorMessage)
end

function TestProcessButtons:testHostChangesStillLightToggleButtons()
    remote.mock("get_item_state"):impl(function()
        return { is_enabled = true, value = 127, remote_item_name = "Ring Mod" }
    end)
    setButtons({ items.button13.index })
    local errorMessage = "expected a toggle button to have the bright colour when the host reports it on"
    lu.assertEquals(state.getNext("button13.colour"), getColour("cyan", 95), errorMessage)
end
