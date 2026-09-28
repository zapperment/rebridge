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
        state.set(pattern .. ".colour", colours.white.bright)
        state.update(pattern .. ".enabled")
        state.update(pattern .. ".hostValue")
        state.update(pattern .. ".colour")
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

function TestDeliverPadColours:testLightsPadMatchingHostValueInPatternColour()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 2)
    state.set("pattern1.colour", colours.red.vibrant)
    local events = deliverPadColours()
    lu.assertEquals(events[2], makeColourEvent(71, colours.red.vibrant))
end

function TestDeliverPadColours:testDeliversPadsAgainWhenColourChanges()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 2)
    deliverPadColours()
    state.set("pattern1.colour", colours.orange.vibrant)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    lu.assertEquals(events[2], makeColourEvent(71, colours.orange.vibrant))
    lu.assertEquals(events[1], makeColourEvent(81, colours.off))
end

function TestDeliverPadColours:testDeliversNothingWhenColourChangesOnDisabledPattern()
    state.set("pattern1.hostValue", 2)
    state.set("pattern1.colour", colours.orange.vibrant)
    lu.assertEquals(deliverPadColours(), {})
end
