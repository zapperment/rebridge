local test = require("test.lib._")
local lu = test.luaUnit
local state = require("src.lib.state._")
local const = require("src.config.constants")
local items = require("src.config.items")
local textToHex = require("src.lib.hex.textToHex")
local deliverEncoders = require("src.deliverMidi.encoders")

require("src.reason.codecs.novation.LCXL3")

TestDeliverEncoders = {}

local function sysex(payload)
    return const.sysexHeader .. " " .. payload .. " f7"
end

-- arrangement 4 with the automatic display allowed (bits 5 and 6 set) or
-- suppressed, which is what the encoder's display config byte encodes
local displayOn = sysex("04 xx 64")
local displayOff = sysex("04 xx 04")

-- the config events carry the encoder in the options, as the "xx" placeholder is
-- only substituted by the host; this collects the targets a config was sent for
local function displayConfigTargets(config)
    local targets = {}
    for _, call in ipairs(remote.mock("make_midi").calls) do
        if call[1] == config then
            table.insert(targets, call[2].x)
        end
    end
    return targets
end

local function contains(events, event)
    for _, candidate in ipairs(events) do
        if candidate == event then
            return true
        end
    end
    return false
end

local function enableEncoder(encoder)
    state.set(encoder .. ".enabled", true)
    deliverEncoders()
    remote.clearMocks()
end

function TestDeliverEncoders:setUp()
    test.resetState()
    remote.clearMocks()
    remote.mock("get_item_name"):impl(function()
        return "Portamento"
    end)
    remote_init()
end

function TestDeliverEncoders:testSuppressesTheDisplayWhenEncoderBecomesDisabled()
    enableEncoder("encoder24")
    state.set("encoder24.enabled", false)
    local events = deliverEncoders()
    local errorMessage = "expected the encoder's display to be suppressed when it becomes disabled"
    lu.assertEquals(contains(events, displayOff), true, errorMessage)
    errorMessage = "expected the display to be suppressed for encoder24 (controller " ..
        items.encoder24.controller .. ")"
    lu.assertEquals(displayConfigTargets(displayOff), { items.encoder24.controller }, errorMessage)
end

function TestDeliverEncoders:testTurnsOffTheLedWhenEncoderBecomesDisabled()
    enableEncoder("encoder24")
    state.set("encoder24.enabled", false)
    local events = deliverEncoders()
    local errorMessage = "expected the encoder's LED to be turned off when it becomes disabled"
    lu.assertEquals(contains(events, sysex("01 53 xx 00 00 00")), true, errorMessage)
end

function TestDeliverEncoders:testSendsNoParamNameForADisabledEncoder()
    enableEncoder("encoder24")
    state.set("encoder24.enabled", false)
    deliverEncoders()
    remote.clearMocks()
    -- the host reporting a value for an encoder that is no longer mapped
    state.set("encoder24.value", 64)
    local events = deliverEncoders()
    local errorMessage = "expected no events for a disabled encoder, but got " .. #events
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverEncoders:testAllowsTheDisplayAgainWhenEncoderBecomesEnabled()
    state.set("encoder24.enabled", true)
    local events = deliverEncoders()
    local errorMessage = "expected the encoder's display to be allowed again when it becomes enabled"
    lu.assertEquals(contains(events, displayOn), true, errorMessage)
    errorMessage = "expected the display to be allowed for encoder24 (controller " ..
        items.encoder24.controller .. ")"
    lu.assertEquals(displayConfigTargets(displayOn), { items.encoder24.controller }, errorMessage)
end

function TestDeliverEncoders:testShowsParamNameWhenEnabledEncoderChanges()
    enableEncoder("encoder24")
    state.set("encoder24.value", 64)
    local events = deliverEncoders()
    local errorMessage = "expected the param name to be sent when an enabled encoder changes"
    lu.assertEquals(contains(events, sysex("06 xx 00 " .. textToHex("Portamento"))), true, errorMessage)
end

function TestDeliverEncoders:testSuppressesTheDisplayOfEveryEncoderWhenPreparingForUse()
    remote.clearMocks()
    remote_prepare_for_use()
    local expected = {}
    for i = 1, 24 do
        table.insert(expected, items["encoder" .. i].controller)
    end
    -- the faders are suppressed at the same time, so keep only the encoders here
    local encoderTargets = {}
    for _, target in ipairs(displayConfigTargets(displayOff)) do
        if target >= items.encoder1.controller then
            table.insert(encoderTargets, target)
        end
    end
    local errorMessage = "expected the display of all 24 encoders to be suppressed when preparing for use, " ..
        "so that an unmapped encoder shows nothing at all"
    lu.assertEquals(encoderTargets, expected, errorMessage)
end
