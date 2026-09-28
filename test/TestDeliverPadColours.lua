local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lppmk3.lib.state._"
local ctrl = require "src.lppmk3.config.controls"
local colours = require "src.lppmk3.lib.colour.config"
local makeColourEvent = require "src.lppmk3.lib.midi.makeColourEvent"
local deliverPadColours = require "src.lppmk3.remote.deliverMidi.padColours"

TestDeliverPadColours = {}

function TestDeliverPadColours:setUp()
    for _, pattern in ipairs(ctrl.patterns) do
        state.set(pattern .. ".enabled", false)
        state.set(pattern .. ".hostValue", nil)
        state.update(pattern .. ".enabled")
        state.update(pattern .. ".hostValue")
    end
end

function TestDeliverPadColours:testLightsPadMatchingHostValueAndTurnsOffOthers()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 3)
    local off = colours.off
    local bright = colours.white.bright
    lu.assertEquals(deliverPadColours(), {
        makeColourEvent(81, off),
        makeColourEvent(71, off),
        makeColourEvent(61, bright),
        makeColourEvent(51, off),
        makeColourEvent(41, off),
        makeColourEvent(31, off),
        makeColourEvent(21, off),
        makeColourEvent(11, off),
    })
end

function TestDeliverPadColours:testTurnsOffAllPadsWhenNoPadMatchesHostValue()
    state.set("pattern2.enabled", true)
    state.set("pattern2.hostValue", 0)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    for _, event in ipairs(events) do
        lu.assertStrContains(event, " 00", false)
        lu.assertNotStrContains(event, " 03")
    end
end

function TestDeliverPadColours:testDeliversNothingWhenHostValueUnchanged()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 3)
    deliverPadColours()
    lu.assertEquals(deliverPadColours(), {})
end

function TestDeliverPadColours:testDeliversNothingWhenPatternDisabled()
    state.set("pattern1.hostValue", 3)
    lu.assertEquals(deliverPadColours(), {})
end
