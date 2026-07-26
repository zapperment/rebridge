local test = require("test.lib._")
local lu = test.luaUnit
local state = require("src.lib.state._")
local const = require("src.config.constants")
local items = require("src.config.items")
local textToHex = require("src.lib.hex.textToHex")
local deliverFaders = require("src.deliverMidi.faders")

require("src.reason.codecs.novation.LCXL3")

TestDeliverFaders = {}

local function paramNameSysex(text)
    return const.sysexHeader .. " 06 xx 00 " .. textToHex(text) .. " f7"
end

function TestDeliverFaders:setUp()
    test.resetState()
    remote.clearMocks()
    remote.mock("get_item_name"):impl(function()
        return "Volume"
    end)
    remote_init()
end

function TestDeliverFaders:testNoEventsWhenNoFaderStateHasChanged()
    local events = deliverFaders()
    local errorMessage = "expected no events when no fader state has changed, but got " .. #events
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverFaders:testShowsParamNameWhenFaderIsInSync()
    state.set("fader1", const.fader.inSync)
    local events = deliverFaders()
    lu.assertEquals(#events, 1, "expected one event for the changed fader, but got " .. #events)
    local errorMessage = "expected the param name to be displayed without a prefix when the fader is in sync"
    lu.assertEquals(events[1], paramNameSysex("Volume"), errorMessage)
end

function TestDeliverFaders:testPrefixesParamNameWithArrowUpWhenFaderIsTooLow()
    state.set("fader1", const.fader.tooLow)
    local events = deliverFaders()
    lu.assertEquals(#events, 1, "expected one event for the changed fader, but got " .. #events)
    local errorMessage = "expected the param name to be prefixed with an arrow up symbol when the fader is too low"
    lu.assertEquals(events[1], paramNameSysex("^ Volume"), errorMessage)
end

function TestDeliverFaders:testPrefixesParamNameWithArrowDownWhenFaderIsTooHigh()
    state.set("fader1", const.fader.tooHigh)
    local events = deliverFaders()
    lu.assertEquals(#events, 1, "expected one event for the changed fader, but got " .. #events)
    local errorMessage = "expected the param name to be prefixed with an arrow down symbol when the fader is too high"
    lu.assertEquals(events[1], paramNameSysex("v Volume"), errorMessage)
end

function TestDeliverFaders:testClearsParamNameWhenFaderIsUnassigned()
    state.set("fader1", const.fader.inSync)
    deliverFaders()
    state.set("fader1", const.fader.unassigned)
    local events = deliverFaders()
    lu.assertEquals(#events, 1, "expected one event for the changed fader, but got " .. #events)
    local errorMessage = "expected the param name to be cleared when the fader is unassigned"
    lu.assertEquals(events[1], paramNameSysex(" "), errorMessage)
end

function TestDeliverFaders:testTargetsTheDisplayOfTheChangedFader()
    state.set("fader3", const.fader.inSync)
    deliverFaders()
    local calls = remote.mock("make_midi").calls
    local lastCall = calls[#calls]
    local errorMessage = "expected the param name display event to target controller " ..
        items.fader3.controller .. ", but it targets " .. tostring(lastCall[2].x)
    lu.assertEquals(lastCall[2].x, items.fader3.controller, errorMessage)
end

function TestDeliverFaders:testDoesNotResendParamNameWhenStatusIsUnchanged()
    state.set("fader1", const.fader.tooLow)
    deliverFaders()
    state.set("fader1", const.fader.tooLow)
    local events = deliverFaders()
    local errorMessage = "expected no events when the fader status has not changed, but got " .. #events
    lu.assertEquals(#events, 0, errorMessage)
end
