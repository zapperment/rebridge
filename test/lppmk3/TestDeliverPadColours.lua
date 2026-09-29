local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lppmk3.lib.state._"
local ctrl = require "src.lppmk3.config.controls"
local const = require "src.lppmk3.config.constants"
local colours = require "src.lppmk3.lib.colour.config"
local makeColourEvent = require "src.lppmk3.lib.midi.makeColourEvent"
local deliverPadColours = require "src.lppmk3.remote.deliverMidi.padColours"

TestDeliverPadColours = {}

local flashing = const.colourBehaviour.flashing
local pulsing = const.colourBehaviour.pulsing

-- the pads of device1, the top row, from left to right
local device1Pads = { 81, 82, 83, 84, 85, 86, 87, 88 }

-- sets the pattern of a device with no switch pending, as while the transport is
-- stopped
local function setValue(device, value)
    state.set(device .. ".hostValue", value)
    state.set(device .. ".playingValue", value)
end

function TestDeliverPadColours:setUp()
    state.set("transport.playing", false)
    state.update "transport.playing"
    for _, device in ipairs(ctrl.devices) do
        state.set(device .. ".enabled", false)
        setValue(device, nil)
        state.update(device .. ".enabled")
        state.update(device .. ".hostValue")
        state.update(device .. ".playingValue")
        for value = 1, const.counts.patternValues do
            state.set(device .. ".colour" .. value, colours.white.dim)
            state.update(device .. ".colour" .. value)
        end
    end
end

function TestDeliverPadColours:testLightsPadMatchingHostValueAndTurnsOffOthers()
    state.set("device1.enabled", true)
    setValue("device1", 3)
    local off = colours.off
    local white = colours.white.dim
    lu.assertEquals(deliverPadColours(), {
        makeColourEvent(81, off),
        makeColourEvent(82, off),
        makeColourEvent(83, white),
        makeColourEvent(84, off),
        makeColourEvent(85, off),
        makeColourEvent(86, off),
        makeColourEvent(87, off),
        makeColourEvent(88, off),
    })
end

function TestDeliverPadColours:testTurnsOffAllPadsWhenNoPadMatchesHostValue()
    state.set("device2.enabled", true)
    setValue("device2", 0)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    for _, event in ipairs(events) do
        lu.assertStrContains(event, " 00", false)
        lu.assertNotStrContains(event, " 01")
    end
end

function TestDeliverPadColours:testDeliversNothingWhenHostValueUnchanged()
    state.set("device1.enabled", true)
    setValue("device1", 3)
    deliverPadColours()
    lu.assertEquals(deliverPadColours(), {})
end

function TestDeliverPadColours:testDeliversNothingWhenPatternDisabled()
    setValue("device1", 3)
    lu.assertEquals(deliverPadColours(), {})
end

function TestDeliverPadColours:testLightsPadMatchingHostValueInColourOfThatValue()
    state.set("device1.enabled", true)
    setValue("device1", 2)
    state.set("device1.colour1", colours.green.vibrant)
    state.set("device1.colour2", colours.red.vibrant)
    local events = deliverPadColours()
    lu.assertEquals(events[2], makeColourEvent(82, colours.red.vibrant))
end

function TestDeliverPadColours:testKeepsColourOfEachValueWhenSwitchingValues()
    state.set("device1.enabled", true)
    setValue("device1", 2)
    state.set("device1.colour2", colours.red.vibrant)
    deliverPadColours()
    setValue("device1", 3)
    lu.assertEquals(deliverPadColours()[3], makeColourEvent(83, colours.white.dim))
    setValue("device1", 2)
    lu.assertEquals(deliverPadColours()[2], makeColourEvent(82, colours.red.vibrant))
end

function TestDeliverPadColours:testDeliversPadsAgainWhenColourChanges()
    state.set("device1.enabled", true)
    setValue("device1", 2)
    deliverPadColours()
    state.set("device1.colour2", colours.orange.vibrant)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    lu.assertEquals(events[2], makeColourEvent(82, colours.orange.vibrant))
    lu.assertEquals(events[1], makeColourEvent(81, colours.off))
end

function TestDeliverPadColours:testDeliversNothingWhenColourChangesOnDisabledPattern()
    setValue("device1", 2)
    state.set("device1.colour2", colours.orange.vibrant)
    lu.assertEquals(deliverPadColours(), {})
end

function TestDeliverPadColours:testShowsUnselectedColouredValuesDim()
    state.set("device1.enabled", true)
    setValue("device1", 2)
    state.set("device1.colour2", colours.red.vibrant)
    state.set("device1.colour5", colours.blue.vibrant)
    lu.assertEquals(deliverPadColours(), {
        makeColourEvent(81, colours.off),
        makeColourEvent(82, colours.red.vibrant),
        makeColourEvent(83, colours.off),
        makeColourEvent(84, colours.off),
        makeColourEvent(85, colours.blue.dim),
        makeColourEvent(86, colours.off),
        makeColourEvent(87, colours.off),
        makeColourEvent(88, colours.off),
    })
end

function TestDeliverPadColours:testShowsColouredValuesDimWhenNoValueIsSelected()
    state.set("device1.enabled", true)
    setValue("device1", 0)
    state.set("device1.colour3", colours.green.vibrant)
    lu.assertEquals(deliverPadColours()[3], makeColourEvent(83, colours.green.dim))
end

function TestDeliverPadColours:testDimsPreviouslySelectedColouredValue()
    state.set("device1.enabled", true)
    setValue("device1", 2)
    state.set("device1.colour2", colours.red.vibrant)
    deliverPadColours()
    setValue("device1", 4)
    local events = deliverPadColours()
    lu.assertEquals(events[2], makeColourEvent(82, colours.red.dim))
    lu.assertEquals(events[4], makeColourEvent(84, colours.white.dim))
end

function TestDeliverPadColours:testTurnsOffAllPadsWhenPatternIsDisabled()
    state.set("device1.enabled", true)
    setValue("device1", 2)
    state.set("device1.colour5", colours.blue.vibrant)
    deliverPadColours()
    state.set("device1.enabled", false)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    for index, padController in ipairs(device1Pads) do
        lu.assertEquals(events[index], makeColourEvent(padController, colours.off))
    end
end

function TestDeliverPadColours:testDeliversNothingMoreOnceDisabledPatternIsCleared()
    state.set("device1.enabled", true)
    setValue("device1", 2)
    deliverPadColours()
    state.set("device1.enabled", false)
    deliverPadColours()
    lu.assertEquals(deliverPadColours(), {})
end

function TestDeliverPadColours:testLightsPadsAgainWhenPatternIsReEnabled()
    state.set("device1.enabled", true)
    setValue("device1", 2)
    deliverPadColours()
    state.set("device1.enabled", false)
    deliverPadColours()
    state.set("device1.enabled", true)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    lu.assertEquals(events[2], makeColourEvent(82, colours.white.dim))
end

function TestDeliverPadColours:testFlashesPendingPadBetweenDimAndBright()
    state.set("transport.playing", true)
    state.set("device1.enabled", true)
    setValue("device1", 2)
    state.set("device1.colour2", colours.red.vibrant)
    state.set("device1.colour5", colours.blue.vibrant)
    deliverPadColours()
    state.set("device1.hostValue", 5)
    lu.assertEquals(deliverPadColours(), {
        makeColourEvent(81, colours.off),
        makeColourEvent(82, colours.red.vibrant, pulsing),
        makeColourEvent(83, colours.off),
        makeColourEvent(84, colours.off),
        makeColourEvent(85, colours.blue.dim),
        makeColourEvent(85, colours.blue.vibrant, flashing),
        makeColourEvent(86, colours.off),
        makeColourEvent(87, colours.off),
        makeColourEvent(88, colours.off),
    })
end

function TestDeliverPadColours:testFlashesPlayingPadBetweenBrightAndDimForPendingStop()
    state.set("transport.playing", true)
    state.set("device1.enabled", true)
    setValue("device1", 2)
    state.set("device1.colour2", colours.red.vibrant)
    deliverPadColours()
    state.set("device1.hostValue", 0)
    local events = deliverPadColours()
    lu.assertEquals(#events, 9)
    lu.assertEquals(events[2], makeColourEvent(82, colours.red.vibrant, pulsing))
    lu.assertEquals(events[3], makeColourEvent(82, colours.red.dim, flashing))
end

function TestDeliverPadColours:testShowsPadsStaticOnceSwitched()
    state.set("transport.playing", true)
    state.set("device1.enabled", true)
    setValue("device1", 2)
    state.set("device1.colour2", colours.red.vibrant)
    state.set("device1.colour5", colours.blue.vibrant)
    deliverPadColours()
    state.set("device1.hostValue", 5)
    deliverPadColours()
    state.set("device1.playingValue", 5)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    lu.assertEquals(events[2], makeColourEvent(82, colours.red.dim))
    lu.assertEquals(events[5], makeColourEvent(85, colours.blue.vibrant, pulsing))
end

function TestDeliverPadColours:testPulsesPlayingPadWhileTransportIsPlaying()
    state.set("transport.playing", true)
    state.set("device1.enabled", true)
    setValue("device1", 2)
    state.set("device1.colour2", colours.red.vibrant)
    state.set("device1.colour5", colours.blue.vibrant)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    lu.assertEquals(events[2], makeColourEvent(82, colours.red.vibrant, pulsing))
    lu.assertEquals(events[5], makeColourEvent(85, colours.blue.dim))
end

function TestDeliverPadColours:testPulsesPlayingPadWhenTransportStarts()
    state.set("device1.enabled", true)
    setValue("device1", 2)
    state.set("device1.colour2", colours.red.vibrant)
    deliverPadColours()
    state.set("transport.playing", true)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    lu.assertEquals(events[2], makeColourEvent(82, colours.red.vibrant, pulsing))
end

function TestDeliverPadColours:testShowsPlayingPadStaticWhenTransportStops()
    state.set("transport.playing", true)
    state.set("device1.enabled", true)
    setValue("device1", 2)
    state.set("device1.colour2", colours.red.vibrant)
    deliverPadColours()
    state.set("transport.playing", false)
    local events = deliverPadColours()
    lu.assertEquals(#events, 8)
    lu.assertEquals(events[2], makeColourEvent(82, colours.red.vibrant))
end

function TestDeliverPadColours:testDeliversNothingForDisabledDeviceWhenTransportStarts()
    setValue("device1", 2)
    deliverPadColours()
    state.set("transport.playing", true)
    lu.assertEquals(deliverPadColours(), {})
end
