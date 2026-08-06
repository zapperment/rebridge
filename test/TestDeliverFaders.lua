local test = require("test.lib._")
local lu = test.luaUnit
local state = require("src.lib.state._")
local const = require("src.config.constants")
local items = require("src.config.items")
local hex = require("src.lib.hex._")
local deliverFaders = require("src.remote.deliverMidi.faders")
local setFaders = require("src.remote.setState.faders")

require("src.reason.codecs.novation.LCXL3")

TestDeliverFaders = {}

local function sysex(payload)
    return const.sysexHeader .. " " .. payload .. " f7"
end

local function paramNameSysex(text)
    return sysex("06 xx 00 " .. hex.textToHex(text))
end

local function valueSysex(text)
    return sysex("06 xx 01 " .. hex.textToHex(text))
end

-- arrangement 1 (name and text value) with the automatic display allowed
-- (bits 5 and 6 set) or suppressed, which is what the fader's own display
-- config byte encodes
local displayOn = sysex("04 xx 61")
local displayOff = sysex("04 xx 01")

-- remote_prepare_for_use suppresses every control before it knows which
-- arrangement each one uses, so it falls back to the default arrangement
-- (name and numeric value) rather than the fader-specific one above
local prepareDisplayOff = sysex("04 xx 04")

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

-- simulates the host reporting the fader as mapped to "Volume"
local function reportFader(fader)
    remote.mock("get_item_state"):impl(function()
        return { is_enabled = true, value = 64, remote_item_name = "Volume", text_value = "64" }
    end)
    setFaders({ items[fader].index })
end

-- brings the fader into the assigned, in-sync state, as the host does when it
-- maps a parameter to it and the control surface's fader is already at the
-- right position
local function assignFader(fader)
    reportFader(fader)
    state.set(fader .. ".status", const.fader.inSync)
    deliverFaders()
    remote.clearMocks()
end

function TestDeliverFaders:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestDeliverFaders:testNoEventsWhenNoFaderStateHasChanged()
    local events = deliverFaders()
    local errorMessage = "expected no events when no fader state has changed, but got " .. #events
    lu.assertEquals(#events, 0, errorMessage)
end

function TestDeliverFaders:testAllowsTheDisplayAndShowsParamNameWhenFaderBecomesAssigned()
    reportFader("fader1")
    state.set("fader1.status", const.fader.inSync)
    local events = deliverFaders()
    local errorMessage = "expected the fader's display to be allowed, the param name sent, and its value shown"
    lu.assertEquals(events, { displayOn, paramNameSysex("Volume"), valueSysex("64") }, errorMessage)
end

function TestDeliverFaders:testShowsTheValueWithoutAPrefixWhenFaderIsInSync()
    assignFader("fader1")
    state.set("fader1.status", const.fader.tooLow)
    deliverFaders()
    state.set("fader1.status", const.fader.inSync)
    local events = deliverFaders()
    lu.assertEquals(#events, 1, "expected one event for the changed fader, but got " .. #events)
    local errorMessage = "expected the value to be displayed without a prefix when the fader is in sync"
    lu.assertEquals(events[1], valueSysex("64"), errorMessage)
end

function TestDeliverFaders:testPrefixesTheValueWithAnArrowUpWhenFaderIsTooLow()
    assignFader("fader1")
    state.set("fader1.status", const.fader.tooLow)
    local events = deliverFaders()
    lu.assertEquals(#events, 1, "expected one event for the changed fader, but got " .. #events)
    local errorMessage = "expected the value to be prefixed with an arrow up symbol when the fader is too low"
    lu.assertEquals(events[1], valueSysex("^ 64 ^"), errorMessage)
end

function TestDeliverFaders:testPrefixesTheValueWithAnArrowDownWhenFaderIsTooHigh()
    assignFader("fader1")
    state.set("fader1.status", const.fader.tooHigh)
    local events = deliverFaders()
    lu.assertEquals(#events, 1, "expected one event for the changed fader, but got " .. #events)
    local errorMessage = "expected the value to be prefixed with an arrow down symbol when the fader is too high"
    lu.assertEquals(events[1], valueSysex("v 64 v"), errorMessage)
end

function TestDeliverFaders:testSuppressesTheDisplayWhenFaderBecomesUnassigned()
    assignFader("fader1")
    state.set("fader1.enabled", false)
    state.set("fader1.status", const.fader.unassigned)
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
    state.set("fader1.status", const.fader.tooHigh)
    local events = deliverFaders()
    local errorMessage = "expected no display config event while the fader is only changing pickup status"
    lu.assertEquals(contains(events, displayOn), false, errorMessage)
    lu.assertEquals(contains(events, displayOff), false, errorMessage)
end

function TestDeliverFaders:testTargetsTheDisplayOfTheChangedFader()
    reportFader("fader3")
    state.set("fader3.status", const.fader.inSync)
    deliverFaders()
    local errorMessage = "expected the param name display event to target controller " ..
        items.fader3.controller
    lu.assertEquals(targetsOf(paramNameSysex("Volume")), { items.fader3.controller }, errorMessage)
end

function TestDeliverFaders:testDoesNotResendParamNameWhenStatusIsUnchanged()
    assignFader("fader1")
    state.set("fader1.status", const.fader.tooLow)
    deliverFaders()
    state.set("fader1.status", const.fader.tooLow)
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
    for _, target in ipairs(targetsOf(prepareDisplayOff)) do
        if target <= items.fader8.controller then
            table.insert(faderTargets, target)
        end
    end
    local errorMessage = "expected the display of all 8 faders to be suppressed when preparing for use, " ..
        "so that an unmapped fader shows nothing at all"
    lu.assertEquals(faderTargets, expected, errorMessage)
end
