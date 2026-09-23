local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lib.state._"
local items = require "src.lcxl3.config.items"
local const = require "src.lcxl3.config.constants"
local processButtons = require "src.remote.processMidi.buttons"

require "src.reason.codecs.novation.LCXL3"

TestProcessButtons = {}

local function setDeviceType(deviceType)
    state.set("deviceType", deviceType)
    state.update "deviceType"
end

local function setParamName(paramName)
    remote.mock "get_item_name":impl(function()
        return paramName
    end)
end

-- the value the host currently reports for the item, scaled to the item's
-- 0-127 range, as the host would have reported it before the button is pressed
local function setHostValue(scaledValue)
    state.set("button13.hostValue", scaledValue)
    state.update "button13.hostValue"
end

local function enableButton(button)
    state.set(button .. ".enabled", true)
    state.update(button .. ".enabled")
end

-- simulates the hardware button being pressed (127) or released (0)
local function sendButton(button, value)
    remote.mock "match_midi":impl(function(midi)
        return midi == items[button].midi and { x = value } or nil
    end)
    processButtons({ time_stamp = 0 })
end

local function handledValues()
    local values = {}
    for _, call in ipairs(remote.mock "handle_input".calls) do
        table.insert(values, call[1].value)
    end
    return values
end

function TestProcessButtons:setUp()
    test.resetState()
    remote.clearMocks()
    setDeviceType "subtractor"
    setParamName "Filter Type"
    setHostValue(0)
    remote_init()
    enableButton "button13"
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

function TestProcessButtons:testRecordsTheControlSurfaceValueWhilePressed()
    sendButton("button13", 127)
    local errorMessage = "expected the control surface value to be recorded as 127 while the button is held down"
    lu.assertEquals(state.get "button13.controlSurfaceValue", 127, errorMessage)
end

function TestProcessButtons:testRecordsTheControlSurfaceValueAfterRelease()
    sendButton("button13", 127)
    sendButton("button13", 0)
    local errorMessage = "expected the control surface value to be recorded as 0 after release"
    lu.assertEquals(state.get "button13.controlSurfaceValue", 0, errorMessage)
end

function TestProcessButtons:testReleaseDoesNotChangeTheHostValue()
    sendButton("button13", 127)
    sendButton("button13", 0)
    local numberOfCalls = #remote.mock "handle_input".calls
    local errorMessage = "expected only the press to update the host, but handle_input was called " ..
        numberOfCalls .. " times"
    lu.assertEquals(numberOfCalls, 1, errorMessage)
end

function TestProcessButtons:testTwoValueParamsStillToggle()
    setParamName "Ring Mod"
    -- a toggle's hostValue is a boolean, not the scaled number used above for
    -- Filter Type's cycling; Lua treats 0 as truthy, so a leftover number here
    -- would corrupt the flip below
    setHostValue(nil)
    sendButton("button13", 127)
    local errorMessage = "expected a two-value parameter to toggle on (127), but the handled values are " ..
        table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 127 }, errorMessage)
    lu.assertEquals(state.get "button13.hostValue", true, "expected the toggle value to flip on")
end

function TestProcessButtons:testTogglesIgnoreTheRelease()
    setParamName "Ring Mod"
    setHostValue(nil)
    sendButton("button13", 127)
    sendButton("button13", 0)
    local numberOfCalls = #remote.mock "handle_input".calls
    local errorMessage = "expected the toggle's release to be ignored, but handle_input was called " ..
        numberOfCalls .. " times"
    lu.assertEquals(numberOfCalls, 1, errorMessage)
    lu.assertEquals(state.get "button13.hostValue", true, "expected the toggle value to still be on")
end

function TestProcessButtons:testCycleParamsAreScopedToTheirDeviceType()
    -- the Combinator defines no cycle parameters, so even a parameter named
    -- like one behaves as a toggle there
    setDeviceType "combinator"
    setHostValue(nil)
    sendButton("button13", 127)
    local errorMessage = "expected the parameter to toggle on a device type without cycle parameters, " ..
        "but the handled values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 127 }, errorMessage)
end

local function makeMomentary()
    setDeviceType "bassline"
    setParamName "Run"
    state.set("button13.type", const.button.momentary)
    state.update "button13.type"
end

function TestProcessButtons:testAMomentaryButtonSendsAPressWhateverTheParamsState()
    makeMomentary()
    setHostValue(false)
    sendButton("button13", 127)
    local errorMessage = "expected a momentary button to send a press (127) even though the parameter is on, " ..
        "as the host flips it itself, but the handled values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 127 }, errorMessage)
end

function TestProcessButtons:testAMomentaryButtonSendsTheReleaseToo()
    -- the host only counts a press once it has seen the button come up again
    makeMomentary()
    setHostValue(false)
    sendButton("button13", 127)
    sendButton("button13", 0)
    local errorMessage = "expected the press and the release to reach the host, but the handled values are " ..
        table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 127, 0 }, errorMessage)
end

function TestProcessButtons:testATwoValueCycleParamStepsBetweenItsValues()
    -- the Bassline Generator's Bank buttons step between bank A (0) and B (127)
    setDeviceType "bassline"
    setParamName "Pattern 2 OnBeat Bank"
    setHostValue(0)
    sendButton("button13", 127)
    setHostValue(127)
    sendButton("button13", 127)
    local errorMessage = "expected the Bank button to step from A to B and back, but the handled values are " ..
        table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 127, 0 }, errorMessage)
end
