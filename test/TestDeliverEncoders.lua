local test = require("test.lib._")
local lu = test.luaUnit
local state = require("src.lib.state._")
local const = require("src.config.constants")
local items = require("src.config.items")
local hex = require("src.lib.hex._")
local deliverEncoders = require("src.deliverMidi.encoders")
local setButtons = require("src.setState.buttons")

require("src.reason.codecs.novation.LCXL3")

TestDeliverEncoders = {}

local function sysex(payload)
    return const.sysexHeader .. " " .. payload .. " f7"
end

-- the encoder's display config byte: allowed (bits 5 and 6 set) with
-- arrangement 1, as the codec provides the value text itself, or suppressed
local displayOn = sysex("04 xx 61")
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
    remote.mock("get_item_text_value"):impl(function()
        return "64"
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
    lu.assertEquals(contains(events, sysex("06 xx 00 " .. hex.textToHex("Portamento"))), true, errorMessage)
end

function TestDeliverEncoders:testShowsTheHostTextValueWhenEnabledEncoderChanges()
    -- the host reports the value in the parameter's own range, e.g. an
    -- Osc Fine Tune turned all the way down is -50, not 0
    remote.mock("get_item_text_value"):impl(function()
        return "-50"
    end)
    -- the encoder is at 0, its lowest position, when it becomes enabled
    state.set("encoder2.enabled", true)
    local events = deliverEncoders()
    local errorMessage = "expected the host's text value to be sent to the display's value field"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex("-50"))), true, errorMessage)
end

function TestDeliverEncoders:testShowsTheNamedWaveformForOscWaveLowValues()
    state.set("deviceType", "subtractor")
    state.update("deviceType")
    remote.mock("get_item_name"):impl(function()
        return "Osc1 Wave"
    end)
    remote.mock("get_item_text_value"):impl(function()
        return "2"
    end)
    enableEncoder("encoder1")
    state.set("encoder1.value", 64)
    local events = deliverEncoders()
    local errorMessage = "expected Osc1 Wave's value 2 to be shown as 'Triangle'"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex("Triangle"))), true, errorMessage)
end

function TestDeliverEncoders:testShowsTheCountedValueForOscWaveHighValues()
    state.set("deviceType", "subtractor")
    state.update("deviceType")
    remote.mock("get_item_name"):impl(function()
        return "Osc2 Wave"
    end)
    remote.mock("get_item_text_value"):impl(function()
        return "31"
    end)
    enableEncoder("encoder3")
    state.set("encoder3.value", 127)
    local events = deliverEncoders()
    local errorMessage = "expected Osc2 Wave's value 31 (the last of 32 values) to be shown as '32'"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex("32"))), true, errorMessage)
end

-- simulates the host reporting the LFO Sync Enable toggle (button10) on or off
local function setLfoSync(on)
    local previousImpl = remote.mock("get_item_state").implementation
    remote.mock("get_item_state"):impl(function()
        return { is_enabled = true, value = on and 127 or 0, remote_item_name = "LFO Sync Enable" }
    end)
    setButtons({ items.button10.index })
    remote.mock("get_item_state").implementation = previousImpl
end

-- delivers an LFO1 Rate change on encoder17 and returns the events
local function deliverLfoRate(value)
    state.set("deviceType", "subtractor")
    state.update("deviceType")
    remote.mock("get_item_name"):impl(function()
        return "LFO1 Rate"
    end)
    remote.mock("get_item_text_value"):impl(function()
        return tostring(value)
    end)
    enableEncoder("encoder17")
    state.set("encoder17.value", value)
    return deliverEncoders()
end

function TestDeliverEncoders:testShowsNoteLengthDivisionsForLfoRateWhileSyncIsEnabled()
    setLfoSync(true)
    local events = deliverLfoRate(64)
    local errorMessage = "expected LFO1 Rate at 64 to be shown as the note-length division '2/4' " ..
        "while LFO sync is enabled"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex("2/4"))), true, errorMessage)
end

function TestDeliverEncoders:testShowsTheOutermostDivisionsAtTheEndsOfTheRange()
    setLfoSync(true)
    local events = deliverLfoRate(1)
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex("16/4"))), true,
        "expected the bottom of the range to be shown as '16/4'")
    events = deliverLfoRate(127)
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex("1/32"))), true,
        "expected the top of the range to be shown as '1/32'")
end

function TestDeliverEncoders:testShowsThePlainRateWhileSyncIsDisabled()
    setLfoSync(false)
    local events = deliverLfoRate(64)
    local errorMessage = "expected LFO1 Rate to be shown as the plain value while LFO sync is disabled"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex("64"))), true, errorMessage)
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
