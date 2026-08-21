local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lib.state._"
local const = require "src.config.constants"
local items = require "src.config.items"
local hex = require "src.lib.hex._"
local deliverEncoders = require "src.remote.deliverMidi.encoders"
local setEncoders = require "src.remote.setState.encoders"
local setButtons = require "src.remote.setState.buttons"

require "src.reason.codecs.novation.LCXL3"

TestDeliverEncoders = {}

local function sysex(payload)
    return const.sysexHeader .. " " .. payload .. " f7"
end

-- the encoder's display config byte: allowed (bits 5 and 6 set) with
-- arrangement 1, as the codec provides the value text itself, or suppressed
local displayOn = sysex "04 xx 61"
local displayOff = sysex "04 xx 01"

-- remote_prepare_for_use suppresses every control before it knows which
-- arrangement each one uses, so it falls back to the default arrangement
-- (name and numeric value) rather than the encoder-specific one above
local prepareDisplayOff = sysex "04 xx 04"

-- the config events carry the encoder in the options, as the "xx" placeholder is
-- only substituted by the host; this collects the targets a config was sent for
local function displayConfigTargets(config)
    local targets = {}
    for _, call in ipairs(remote.mock "make_midi".calls) do
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

-- simulates the host reporting the encoder as mapped to the given parameter
local function reportEncoder(encoder, paramName, hostValue, textValue)
    remote.mock "get_item_state":impl(function()
        return { is_enabled = true, value = hostValue, remote_item_name = paramName, text_value = textValue }
    end)
    setEncoders({ items[encoder].index })
end

local function enableEncoder(encoder)
    reportEncoder(encoder, "Portamento", 64, "64")
    deliverEncoders()
    remote.clearMocks()
end

function TestDeliverEncoders:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestDeliverEncoders:testSuppressesTheDisplayWhenEncoderBecomesDisabled()
    enableEncoder "encoder24"
    state.set("encoder24.enabled", false)
    local events = deliverEncoders()
    local errorMessage = "expected the encoder's display to be suppressed when it becomes disabled"
    lu.assertEquals(contains(events, displayOff), true, errorMessage)
    errorMessage = "expected the display to be suppressed for encoder24 (controller " ..
        items.encoder24.controller .. ")"
    lu.assertEquals(displayConfigTargets(displayOff), { items.encoder24.controller }, errorMessage)
end

function TestDeliverEncoders:testTurnsOffTheLedWhenEncoderBecomesDisabled()
    enableEncoder "encoder24"
    state.set("encoder24.enabled", false)
    local events = deliverEncoders()
    local errorMessage = "expected the encoder's LED to be turned off when it becomes disabled"
    lu.assertEquals(contains(events, sysex "01 53 xx 00 00 00"), true, errorMessage)
end

function TestDeliverEncoders:testSendsNoParamNameForADisabledEncoder()
    enableEncoder "encoder24"
    state.set("encoder24.enabled", false)
    deliverEncoders()
    remote.clearMocks()
    -- the host reporting a value for an encoder that is no longer mapped
    state.set("encoder24.hostValue", 64)
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

function TestDeliverEncoders:testShowsParamNameWhenEncoderBecomesEnabled()
    reportEncoder("encoder24", "Portamento", 64, "64")
    local events = deliverEncoders()
    local errorMessage = "expected the param name to be sent when an encoder becomes enabled"
    lu.assertEquals(contains(events, sysex("06 xx 00 " .. hex.textToHex "Portamento")), true, errorMessage)
end

function TestDeliverEncoders:testShowsTheHostTextValueWhenEncoderBecomesEnabled()
    -- the host reports the value in the parameter's own range, e.g. an
    -- Osc Fine Tune turned all the way down is -50, not 0
    reportEncoder("encoder2", "Fine Tune", 0, "-50")
    local events = deliverEncoders()
    local errorMessage = "expected the host's text value to be sent to the display's value field"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "-50")), true, errorMessage)
end

function TestDeliverEncoders:testShowsTheNamedWaveformForOscWaveLowValues()
    state.set("deviceType", "subtractor")
    state.update "deviceType"
    reportEncoder("encoder1", "Osc1 Wave", 8, "2")
    local events = deliverEncoders()
    local errorMessage = "expected Osc1 Wave's value 2 to be shown as 'Triangle'"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "Triangle")), true, errorMessage)
end

function TestDeliverEncoders:testShowsTheCountedValueForOscWaveHighValues()
    state.set("deviceType", "subtractor")
    state.update "deviceType"
    reportEncoder("encoder3", "Osc2 Wave", 127, "31")
    local events = deliverEncoders()
    local errorMessage = "expected Osc2 Wave's value 31 (the last of 32 values) to be shown as '32'"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "32")), true, errorMessage)
end

-- simulates the host reporting the LFO Sync Enable toggle (button10) on or off
local function setLfoSync(on)
    local previousImpl = remote.mock "get_item_state".implementation
    remote.mock "get_item_state":impl(function()
        return { is_enabled = true, value = on and 127 or 0, remote_item_name = "LFO Sync Enable" }
    end)
    setButtons({ items.button10.index })
    remote.mock "get_item_state".implementation = previousImpl
end

-- delivers an LFO1 Rate change on encoder17 and returns the events
local function deliverLfoRate(value)
    state.set("deviceType", "subtractor")
    state.update "deviceType"
    reportEncoder("encoder17", "LFO1 Rate", value, tostring(value))
    return deliverEncoders()
end

function TestDeliverEncoders:testShowsNoteLengthDivisionsForLfoRateWhileSyncIsEnabled()
    setLfoSync(true)
    local events = deliverLfoRate(64)
    local errorMessage = "expected LFO1 Rate at 64 to be shown as the note-length division '2/4' " ..
        "while LFO sync is enabled"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "2/4")), true, errorMessage)
end

function TestDeliverEncoders:testShowsTheOutermostDivisionsAtTheEndsOfTheRange()
    setLfoSync(true)
    local events = deliverLfoRate(1)
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "16/4")), true,
        "expected the bottom of the range to be shown as '16/4'")
    events = deliverLfoRate(127)
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "1/32")), true,
        "expected the top of the range to be shown as '1/32'")
end

function TestDeliverEncoders:testShowsThePlainRateWhileSyncIsDisabled()
    setLfoSync(false)
    local events = deliverLfoRate(64)
    local errorMessage = "expected LFO1 Rate to be shown as the plain value while LFO sync is disabled"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "64")), true, errorMessage)
end

-- simulates the host reporting one of Ripley's delay switches on or off
local function setRipleySwitch(button, param, on)
    local previousImpl = remote.mock "get_item_state".implementation
    remote.mock "get_item_state":impl(function()
        return { is_enabled = true, value = on and 127 or 0, remote_item_name = param }
    end)
    setButtons({ items[button].index })
    remote.mock "get_item_state".implementation = previousImpl
end

local function setDualDelay(on)
    setRipleySwitch("button12", "Dual Delay", on)
end

-- Ripley's Delay Time has a list of conditionals, so which of the parameters it
-- depends on changed does not matter: whenever one of them does, the encoder has
-- to be delivered again, or it would keep showing whatever it showed before
function TestDeliverEncoders:testShowsTheDelayTimeAgainWhenDualDelayIsTurnedOff()
    state.set("deviceType", "ripley")
    state.update "deviceType"
    setDualDelay(false)
    reportEncoder("encoder1", "Delay Time", 64, "250 ms")
    deliverEncoders()
    -- the single delay time gives way to the separate times per channel
    setDualDelay(true)
    local events = deliverEncoders()
    local errorMessage = "expected nothing to be shown for Delay Time while Dual Delay is turned on"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "250 ms")), false, errorMessage)
    remote.clearMocks()
    setDualDelay(false)
    events = deliverEncoders()
    errorMessage = "expected Delay Time to be shown again when Dual Delay is turned off, " ..
        "even though the encoder's own value did not change"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "250 ms")), true, errorMessage)
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
    for _, target in ipairs(displayConfigTargets(prepareDisplayOff)) do
        if target >= items.encoder1.controller then
            table.insert(encoderTargets, target)
        end
    end
    local errorMessage = "expected the display of all 24 encoders to be suppressed when preparing for use, " ..
        "so that an unmapped encoder shows nothing at all"
    lu.assertEquals(encoderTargets, expected, errorMessage)
end
