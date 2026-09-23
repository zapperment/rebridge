local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lcxl3.lib.state._"
local const = require "src.lcxl3.config.constants"
local items = require "src.lcxl3.config.items"
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

-- the encoder's LED, turned off
local ledOff = sysex "01 53 xx 00 00 00"

-- the sysex events carry the encoder in the options, as the "xx" placeholder is
-- only substituted by the host; this collects the targets an event was sent for
local function sysexTargets(event)
    local targets = {}
    for _, call in ipairs(remote.mock "make_midi".calls) do
        if call[1] == event then
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
    lu.assertEquals(sysexTargets(displayOff), { items.encoder24.controller }, errorMessage)
end

function TestDeliverEncoders:testTurnsOffTheLedWhenEncoderBecomesDisabled()
    enableEncoder "encoder24"
    state.set("encoder24.enabled", false)
    local events = deliverEncoders()
    local errorMessage = "expected the encoder's LED to be turned off when it becomes disabled"
    lu.assertEquals(contains(events, ledOff), true, errorMessage)
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
    lu.assertEquals(sysexTargets(displayOn), { items.encoder24.controller }, errorMessage)
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

local function setDelayTempoSync(on)
    setRipleySwitch("button10", "Delay Tempo Sync", on)
end

-- Ripley's Delay Time R and its Synced Time R share encoder2, and neither of
-- them is in force while Dual Delay is off: with a single delay there is no
-- right-hand channel to give the encoder a parameter at all
local function reportRipleyRightHandDelay()
    state.set("deviceType", "ripley")
    state.update "deviceType"
    reportEncoder("encoder2", "Delay Time R", 64, "250 ms")
    reportEncoder("encoder2alt", "Synced Time R", 32, "1/8")
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

function TestDeliverEncoders:testTurnsOffTheEncoderWhenNoneOfItsParamsIsInForceAnyMore()
    reportRipleyRightHandDelay()
    setDelayTempoSync(false)
    setDualDelay(true)
    deliverEncoders()
    remote.clearMocks()
    -- back to a single delay time, leaving encoder2 with no parameter of its own
    setDualDelay(false)
    local events = deliverEncoders()
    local errorMessage = "expected the LED of encoder2 (controller " .. items.encoder2.controller .. ") " ..
        "to be turned off when neither Delay Time R nor Synced Time R is in force"
    lu.assertEquals(sysexTargets(ledOff), { items.encoder2.controller }, errorMessage)
    errorMessage = "expected the display of encoder2 to be suppressed, so that turning it " ..
        "brings up nothing at all"
    lu.assertEquals(sysexTargets(displayOff), { items.encoder2.controller }, errorMessage)
    errorMessage = "expected no value to be shown for a parameter that is not in force"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "250 ms")), false, errorMessage)
end

function TestDeliverEncoders:testSendsNothingWhileNoneOfAnEncodersParamsIsInForce()
    reportRipleyRightHandDelay()
    setDelayTempoSync(false)
    setDualDelay(false)
    deliverEncoders()
    remote.clearMocks()
    -- the host keeps reporting the parameter, even though nothing uses it
    reportEncoder("encoder2", "Delay Time R", 100, "500 ms")
    local events = deliverEncoders()
    local errorMessage = "expected an encoder none of whose parameters is in force to be left alone, " ..
        "but got " .. #events .. " events"
    lu.assertEquals(#events, 0, errorMessage)
end

-- the parameter name is only sent when it changes, so an encoder that takes over
-- the display has to send its own name again: it never got the chance to while
-- another parameter had the encoder
function TestDeliverEncoders:testShowsTheParamNameWhenAnEncoderTakesOverTheDisplay()
    reportRipleyRightHandDelay()
    setDelayTempoSync(false)
    setDualDelay(false)
    deliverEncoders()
    remote.clearMocks()
    -- the second delay time comes into use, and with it encoder2's parameter
    setDualDelay(true)
    local events = deliverEncoders()
    local errorMessage = "expected Delay Time R to name itself when it takes over encoder2"
    lu.assertEquals(contains(events, sysex("06 xx 00 " .. hex.textToHex "Delay Time R")), true, errorMessage)
    errorMessage = "expected Delay Time R to show its value when it takes over encoder2"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "250 ms")), true, errorMessage)
    errorMessage = "expected the display of encoder2 (controller " .. items.encoder2.controller .. ") " ..
        "to be allowed again"
    lu.assertEquals(sysexTargets(displayOn), { items.encoder2.controller }, errorMessage)
    errorMessage = "expected the LED of encoder2 to be lit again"
    lu.assertEquals(sysexTargets(ledOff), {}, errorMessage)
end

function TestDeliverEncoders:testShowsTheSyncedTimeWhenTempoSyncTakesOverTheEncoder()
    reportRipleyRightHandDelay()
    setDelayTempoSync(false)
    setDualDelay(true)
    deliverEncoders()
    remote.clearMocks()
    -- the delay time is given in note lengths from here on
    setDelayTempoSync(true)
    local events = deliverEncoders()
    local errorMessage = "expected Synced Time R to name itself when it takes over encoder2 from Delay Time R"
    lu.assertEquals(contains(events, sysex("06 xx 00 " .. hex.textToHex "Synced Time R")), true, errorMessage)
    errorMessage = "expected Synced Time R to show its own value"
    lu.assertEquals(contains(events, sysex("06 xx 01 " .. hex.textToHex "1/8")), true, errorMessage)
    errorMessage = "expected the replaced Delay Time R to name itself no longer"
    lu.assertEquals(contains(events, sysex("06 xx 00 " .. hex.textToHex "Delay Time R")), false, errorMessage)
    errorMessage = "expected the encoder to stay lit while one of its parameters is in force"
    lu.assertEquals(sysexTargets(ledOff), {}, errorMessage)
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
    for _, target in ipairs(sysexTargets(prepareDisplayOff)) do
        if target >= items.encoder1.controller then
            table.insert(encoderTargets, target)
        end
    end
    local errorMessage = "expected the display of all 24 encoders to be suppressed when preparing for use, " ..
        "so that an unmapped encoder shows nothing at all"
    lu.assertEquals(encoderTargets, expected, errorMessage)
end
