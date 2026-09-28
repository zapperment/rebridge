local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lppmk3.lib.state._"
local ctrl = require "src.lppmk3.config.controls"
local const = require "src.lppmk3.config.constants"
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
        for value = 1, const.counts.patternValues do
            state.set(pattern .. ".colour" .. value, colours.white.dim)
            state.update(pattern .. ".colour" .. value)
        end
    end
end

function TestDeliverPadColours:testLightsPadMatchingHostValueAndTurnsOffOthers()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 3)
    local off = colours.off
    local white = colours.white.dim
    lu.assertEquals(deliverPadColours(), {
        makeColourEvent(81, off),
        makeColourEvent(71, off),
        makeColourEvent(61, white),
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
        lu.assertNotStrContains(event, " 01")
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

function TestDeliverPadColours:testLightsPadMatchingHostValueInColourOfThatValue()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 2)
    state.set("pattern1.colour1", colours.green.vibrant)
    state.set("pattern1.colour2", colours.red.vibrant)
    local events = deliverPadColours()
    lu.assertEquals(events[2], makeColourEvent(71, colours.red.vibrant))
end

function TestDeliverPadColours:testKeepsColourOfEachValueWhenSwitchingValues()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 2)
    state.set("pattern1.colour2", colours.red.vibrant)
    deliverPadColours()
    state.set("pattern1.hostValue", 3)
    lu.assertEquals(deliverPadColours()[3], makeColourEvent(61, colours.white.dim))
    state.set("pattern1.hostValue", 2)
    lu.assertEquals(deliverPadColours()[2], makeColourEvent(71, colours.red.vibrant))
end

function TestDeliverPadColours:testDeliversPadsAgainWhenColourChanges()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 2)
    deliverPadColours()
    state.set("pattern1.colour2", colours.orange.vibrant)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    lu.assertEquals(events[2], makeColourEvent(71, colours.orange.vibrant))
    lu.assertEquals(events[1], makeColourEvent(81, colours.off))
end

function TestDeliverPadColours:testDeliversNothingWhenColourChangesOnDisabledPattern()
    state.set("pattern1.hostValue", 2)
    state.set("pattern1.colour2", colours.orange.vibrant)
    lu.assertEquals(deliverPadColours(), {})
end

function TestDeliverPadColours:testShowsUnselectedColouredValuesDim()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 2)
    state.set("pattern1.colour2", colours.red.vibrant)
    state.set("pattern1.colour5", colours.blue.vibrant)
    lu.assertEquals(deliverPadColours(), {
        makeColourEvent(81, colours.off),
        makeColourEvent(71, colours.red.vibrant),
        makeColourEvent(61, colours.off),
        makeColourEvent(51, colours.off),
        makeColourEvent(41, colours.blue.dim),
        makeColourEvent(31, colours.off),
        makeColourEvent(21, colours.off),
        makeColourEvent(11, colours.off),
    })
end

function TestDeliverPadColours:testShowsColouredValuesDimWhenNoValueIsSelected()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 0)
    state.set("pattern1.colour3", colours.green.vibrant)
    lu.assertEquals(deliverPadColours()[3], makeColourEvent(61, colours.green.dim))
end

function TestDeliverPadColours:testDimsPreviouslySelectedColouredValue()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 2)
    state.set("pattern1.colour2", colours.red.vibrant)
    deliverPadColours()
    state.set("pattern1.hostValue", 4)
    local events = deliverPadColours()
    lu.assertEquals(events[2], makeColourEvent(71, colours.red.dim))
    lu.assertEquals(events[4], makeColourEvent(51, colours.white.dim))
end

function TestDeliverPadColours:testTurnsOffAllPadsWhenPatternIsDisabled()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 2)
    state.set("pattern1.colour5", colours.blue.vibrant)
    deliverPadColours()
    state.set("pattern1.enabled", false)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    for index, padController in ipairs({ 81, 71, 61, 51, 41, 31, 21, 11 }) do
        lu.assertEquals(events[index], makeColourEvent(padController, colours.off))
    end
end

function TestDeliverPadColours:testDeliversNothingMoreOnceDisabledPatternIsCleared()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 2)
    deliverPadColours()
    state.set("pattern1.enabled", false)
    deliverPadColours()
    lu.assertEquals(deliverPadColours(), {})
end

function TestDeliverPadColours:testLightsPadsAgainWhenPatternIsReEnabled()
    state.set("pattern1.enabled", true)
    state.set("pattern1.hostValue", 2)
    deliverPadColours()
    state.set("pattern1.enabled", false)
    deliverPadColours()
    state.set("pattern1.enabled", true)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    lu.assertEquals(events[2], makeColourEvent(71, colours.white.dim))
end
