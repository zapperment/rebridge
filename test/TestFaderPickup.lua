local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lib.state._"
local const = require "src.lcxl3.config.constants"
local items = require "src.config.items"
local setFaders = require "src.remote.setState.faders"
local processFaders = require "src.remote.processMidi.faders"

require "src.reason.codecs.novation.LCXL3"

TestFaderPickup = {}

-- simulates the host mapping the fader to "Volume" and reporting the given
-- value for it, which is what happens when a song is loaded
local function reportFader(fader, hostValue)
    remote.mock "get_item_state":impl(function()
        return {
            is_enabled = true,
            value = hostValue,
            remote_item_name = "Volume",
            text_value = tostring(hostValue)
        }
    end)
    setFaders({ items[fader].index })
end

-- simulates the hardware fader being moved to the given position
local function moveFader(fader, controlSurfaceValue)
    remote.mock "match_midi":impl(function(midi)
        return midi == items[fader].midi and { x = controlSurfaceValue } or nil
    end)
    processFaders({ time_stamp = 0 })
end

local function handledValues()
    local values = {}
    for _, call in ipairs(remote.mock "handle_input".calls) do
        table.insert(values, call[1].value)
    end
    return values
end

function TestFaderPickup:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestFaderPickup:testTheFaderPositionIsUnknownBeforeTheHardwareFaderHasBeenMoved()
    local errorMessage = "expected the fader position to be unknown until the hardware fader sends a value, " ..
        "as assuming a position lets the host pick up a fader that is nowhere near it"
    lu.assertEquals(state.get "fader1.controlSurfaceValue", nil, errorMessage)
end

function TestFaderPickup:testMarksTheFaderAsUnknownWhenASongIsLoaded()
    reportFader("fader1", 50)
    local errorMessage = "expected the fader to be marked as unknown when the host reports a value " ..
        "before the hardware fader has been moved"
    lu.assertEquals(state.get "fader1.status", const.fader.unknown, errorMessage)
end

function TestFaderPickup:testDoesNotUpdateTheHostOnTheFirstMoveOfAFaderSittingAboveTheHostValue()
    -- the song was just loaded with the parameter at 50, while the hardware
    -- fader happens to sit at 100
    reportFader("fader1", 50)
    moveFader("fader1", 101)
    local errorMessage = "expected no host update on the first move of a fader that sits above the host " ..
        "value, but the handled values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), {}, errorMessage)
    lu.assertEquals(state.get "fader1.status", const.fader.tooHigh,
        "expected the fader to be marked as too high so the display asks for it to be moved down")
end

function TestFaderPickup:testDoesNotUpdateTheHostOnTheFirstMoveOfAFaderSittingBelowTheHostValue()
    reportFader("fader1", 100)
    moveFader("fader1", 21)
    local errorMessage = "expected no host update on the first move of a fader that sits below the host " ..
        "value, but the handled values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), {}, errorMessage)
    lu.assertEquals(state.get "fader1.status", const.fader.tooLow,
        "expected the fader to be marked as too low so the display asks for it to be moved up")
end

function TestFaderPickup:testPicksUpAFaderThatIsMovedDownThroughTheHostValue()
    reportFader("fader1", 50)
    moveFader("fader1", 101)
    moveFader("fader1", 80)
    lu.assertEquals(handledValues(), {}, "expected the host to stay untouched while the fader is still above it")
    moveFader("fader1", 50)
    local errorMessage = "expected the host to be updated once the fader reaches the host value, but " ..
        "the handled values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 50 }, errorMessage)
    lu.assertEquals(state.get "fader1.status", const.fader.inSync, "expected the fader to be in sync")
end

function TestFaderPickup:testPicksUpAFaderThatIsMovedUpThroughTheHostValue()
    reportFader("fader1", 100)
    moveFader("fader1", 21)
    moveFader("fader1", 60)
    lu.assertEquals(handledValues(), {}, "expected the host to stay untouched while the fader is still below it")
    moveFader("fader1", 100)
    local errorMessage = "expected the host to be updated once the fader reaches the host value, but " ..
        "the handled values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 100 }, errorMessage)
    lu.assertEquals(state.get "fader1.status", const.fader.inSync, "expected the fader to be in sync")
end

function TestFaderPickup:testPicksUpImmediatelyWhenTheFaderIsAlreadyWithinTheTolerance()
    reportFader("fader1", 50)
    moveFader("fader1", 50 + const.pickupTolerance)
    local errorMessage = "expected a fader that is already close to the host value to pick up straight away, " ..
        "but the handled values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 50 + const.pickupTolerance }, errorMessage)
end

function TestFaderPickup:testKeepsFollowingTheFaderOnceItIsInSync()
    reportFader("fader1", 50)
    moveFader("fader1", 50)
    moveFader("fader1", 70)
    moveFader("fader1", 90)
    local errorMessage = "expected every move after pickup to be passed on to the host, but the handled " ..
        "values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), { 50, 70, 90 }, errorMessage)
end

function TestFaderPickup:testRequiresPickupAgainWhenTheHostValueMovesAwayFromTheFader()
    -- e.g. another song, patch or track is loaded while the hardware fader stays put
    reportFader("fader1", 50)
    moveFader("fader1", 50)
    reportFader("fader1", 120)
    lu.assertEquals(state.get "fader1.status", const.fader.tooLow,
        "expected the fader to need picking up again after the host value moved above it")
    remote.mock "handle_input":clear()
    moveFader("fader1", 60)
    local errorMessage = "expected no host update while the fader is below the new host value, but the " ..
        "handled values are " .. table.concat(handledValues(), ", ")
    lu.assertEquals(handledValues(), {}, errorMessage)
end

function TestFaderPickup:testAnUnmappedFaderIsMarkedAsUnassigned()
    remote.mock "get_item_state":impl(function()
        return { is_enabled = false }
    end)
    setFaders({ items.fader1.index })
    lu.assertEquals(state.get "fader1.status", const.fader.unassigned,
        "expected a fader the host has not mapped to be marked as unassigned")
end
