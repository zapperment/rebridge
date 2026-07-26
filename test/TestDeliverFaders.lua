local test = require("test.lib._")
local lu = test.luaUnit
local state = require("src.lib.state._")
local const = require("src.config.constants")
local items = require("src.config.items")
local textToHex = require("src.lib.hex.textToHex")
local deliverFaders = require("src.deliverMidi.faders")

require("src.reason.codecs.novation.LCXL3")

TestDeliverFaders = {}

local function sysex(payload)
    return const.sysexHeader .. " " .. payload .. " f7"
end

local function paramNameSysex(text)
    return sysex("06 xx 00 " .. textToHex(text))
end

-- arrangement 4 with the automatic display allowed (bits 5 and 6 set) or
-- suppressed, which is what the fader's display config byte encodes
local displayOn = sysex("04 xx 64")
local displayOff = sysex("04 xx 04")

-- the events carry the fader in the options, as the "xx" placeholder is only
-- substituted by the host; this collects the targets an event was sent for
local function targetsOf(event)
    local targets = {}
    for _, call in ipairs(remote.mock("make_midi").calls) do
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

-- brings the fader into the assigned state, as the host does when it maps a
-- parameter to it
local function assignFader(fader)
    state.set(fader, const.fader.inSync)
    deliverFaders()
    remote.clearMocks()
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

function TestDeliverFaders:testAllowsTheDisplayAndShowsParamNameWhenFaderBecomesAssigned()
    state.set("fader1", const.fader.inSync)
    local events = deliverFaders()
    local errorMessage = "expected the fader's display to be allowed and the param name to be sent"
    lu.assertEquals(events, { displayOn, paramNameSysex("Volume") }, errorMessage)
end

function TestDeliverFaders:testShowsParamNameWhenFaderIsInSync()
    assignFader("fader1")
    state.set("fader1", const.fader.tooLow)
    deliverFaders()
    state.set("fader1", const.fader.inSync)
    local events = deliverFaders()
    lu.assertEquals(#events, 1, "expected one event for the changed fader, but got " .. #events)
    local errorMessage = "expected the param name to be displayed without a prefix when the fader is in sync"
    lu.assertEquals(events[1], paramNameSysex("Volume"), errorMessage)
end

function TestDeliverFaders:testPrefixesParamNameWithArrowUpWhenFaderIsTooLow()
    assignFader("fader1")
    state.set("fader1", const.fader.tooLow)
    local events = deliverFaders()
    lu.assertEquals(#events, 1, "expected one event for the changed fader, but got " .. #events)
    local errorMessage = "expected the param name to be prefixed with an arrow up symbol when the fader is too low"
    lu.assertEquals(events[1], paramNameSysex("^ Volume"), errorMessage)
end

function TestDeliverFaders:testPrefixesParamNameWithArrowDownWhenFaderIsTooHigh()
    assignFader("fader1")
    state.set("fader1", const.fader.tooHigh)
    local events = deliverFaders()
    lu.assertEquals(#events, 1, "expected one event for the changed fader, but got " .. #events)
    local errorMessage = "expected the param name to be prefixed with an arrow down symbol when the fader is too high"
    lu.assertEquals(events[1], paramNameSysex("v Volume"), errorMessage)
end

function TestDeliverFaders:testSuppressesTheDisplayWhenFaderBecomesUnassigned()
    assignFader("fader1")
    state.set("fader1", const.fader.unassigned)
    local events = deliverFaders()
    local errorMessage = "expected the fader's display to be suppressed when it becomes unassigned, " ..
        "so that moving it shows neither param name nor value"
    lu.assertEquals(events, { displayOff }, errorMessage)
    errorMessage = "expected the display to be suppressed for fader1 (controller " ..
        items.fader1.controller .. ")"
    lu.assertEquals(targetsOf(displayOff), { items.fader1.controller }, errorMessage)
end

function TestDeliverFaders:testDoesNotResendTheDisplayConfigWhileThePickupStatusChanges()
    assignFader("fader1")
    state.set("fader1", const.fader.tooHigh)
    local events = deliverFaders()
    local errorMessage = "expected no display config event while the fader is only changing pickup status"
    lu.assertEquals(contains(events, displayOn), false, errorMessage)
    lu.assertEquals(contains(events, displayOff), false, errorMessage)
end

function TestDeliverFaders:testTargetsTheDisplayOfTheChangedFader()
    state.set("fader3", const.fader.inSync)
    deliverFaders()
    local errorMessage = "expected the param name display event to target controller " ..
        items.fader3.controller
    lu.assertEquals(targetsOf(paramNameSysex("Volume")), { items.fader3.controller }, errorMessage)
end

function TestDeliverFaders:testDoesNotResendParamNameWhenStatusIsUnchanged()
    assignFader("fader1")
    state.set("fader1", const.fader.tooLow)
    deliverFaders()
    state.set("fader1", const.fader.tooLow)
    local events = deliverFaders()
    local errorMessage = "expected no events when the fader status has not changed, but got " .. #events
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverFaders:testSuppressesTheDisplayOfEveryFaderWhenPreparingForUse()
    remote.clearMocks()
    remote_prepare_for_use()
    local expected = {}
    for i = 1, 8 do
        table.insert(expected, items["fader" .. i].controller)
    end
    local faderTargets = {}
    for _, target in ipairs(targetsOf(displayOff)) do
        if target <= items.fader8.controller then
            table.insert(faderTargets, target)
        end
    end
    local errorMessage = "expected the display of all 8 faders to be suppressed when preparing for use, " ..
        "so that an unmapped fader shows nothing at all"
    lu.assertEquals(faderTargets, expected, errorMessage)
end
