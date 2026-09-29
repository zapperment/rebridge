local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lppmk3.config.constants"
local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"
local colours = require "src.lppmk3.lib.colour.config"
local makeColourEvent = require "src.lppmk3.lib.midi.makeColourEvent"
local setTransport = require "src.lppmk3.remote.setState.transport"
local deliverSwitchMeter = require "src.lppmk3.remote.deliverMidi.switchMeter"
local defineItemIndices = require "test.lppmk3.defineItemIndices"

TestDeliverSwitchMeter = {}

local pulsing = const.colourBehaviour.pulsing
local off = colours.off
local beat = const.songPositionPerBar / 4

-- the timer values for 1 and 2 bars
local oneBar = 3
local twoBars = 4

local function setUpMeter(timer, songPosition, playing)
  state.set("patternTimer", timer)
  state.set("songPosition", songPosition)
  state.set("transport.playing", playing)
end

function TestDeliverSwitchMeter:setUp()
  remote.clearMocks()
  defineItemIndices()
  setUpMeter(0, nil, false)
  -- the meter starts out dark
  deliverSwitchMeter()
end

-- the look of each button starts out unknown, so the first delivery sends the
-- whole row, turning it dark from the start
function TestDeliverSwitchMeter:testStartsOutUnknown()
  local StateManager = require "src.lppmk3.lib.state.StateManager"
  local stateManager = StateManager:new()
  for button = 1, const.counts.switchMeterButtons do
    lu.assertNil(stateManager:get("switchMeter.button" .. button .. ".colour"))
  end
end

function TestDeliverSwitchMeter:testLightsFirstButtonDuringFirstBeatOfTwoBars()
  setUpMeter(twoBars, 0, true)
  lu.assertEquals(deliverSwitchMeter(), {
    makeColourEvent(101, colours.green.vibrant, pulsing),
  })
end

function TestDeliverSwitchMeter:testLightsWholeRowInItsColoursDuringLastBeat()
  setUpMeter(twoBars, 7 * beat, true)
  lu.assertEquals(deliverSwitchMeter(), {
    makeColourEvent(101, colours.green.vibrant, pulsing),
    makeColourEvent(102, colours.green.vibrant, pulsing),
    makeColourEvent(103, colours.green.vibrant, pulsing),
    makeColourEvent(104, colours.green.vibrant, pulsing),
    makeColourEvent(105, colours.green.vibrant, pulsing),
    makeColourEvent(106, colours.yellow.vibrant, pulsing),
    makeColourEvent(107, colours.yellow.vibrant, pulsing),
    makeColourEvent(108, colours.red.vibrant, pulsing),
  })
end

function TestDeliverSwitchMeter:testSendsOnlyTheNextButtonAsPlaybackMovesOn()
  setUpMeter(twoBars, 2 * beat, true)
  deliverSwitchMeter()
  state.set("songPosition", 3 * beat)
  lu.assertEquals(deliverSwitchMeter(), {
    makeColourEvent(104, colours.green.vibrant, pulsing),
  })
end

function TestDeliverSwitchMeter:testSendsNothingWithinAStep()
  setUpMeter(twoBars, 2 * beat, true)
  deliverSwitchMeter()
  state.set("songPosition", 2 * beat + 10)
  lu.assertEquals(deliverSwitchMeter(), {})
end

function TestDeliverSwitchMeter:testStepIsAQuaverWithOneBar()
  setUpMeter(oneBar, beat / 2, true)
  lu.assertEquals(#deliverSwitchMeter(), 2)
end

function TestDeliverSwitchMeter:testTurnsButtonsOffWhenNextIntervalStarts()
  setUpMeter(oneBar, 7 * beat / 2, true)
  deliverSwitchMeter()
  state.set("songPosition", 4 * beat)
  local events = deliverSwitchMeter()
  lu.assertEquals(#events, 7)
  lu.assertEquals(events[1], makeColourEvent(102, off))
  lu.assertEquals(events[7], makeColourEvent(108, off))
end

function TestDeliverSwitchMeter:testShowsLitButtonsDimAndStaticWhenStopped()
  setUpMeter(twoBars, 5 * beat, false)
  local events = deliverSwitchMeter()
  lu.assertEquals(#events, 6)
  lu.assertEquals(events[1], makeColourEvent(101, colours.green.dim))
  lu.assertEquals(events[6], makeColourEvent(106, colours.yellow.dim))
end

function TestDeliverSwitchMeter:testRelightsLitButtonsWhenTransportStops()
  setUpMeter(twoBars, beat, true)
  deliverSwitchMeter()
  state.set("transport.playing", false)
  lu.assertEquals(deliverSwitchMeter(), {
    makeColourEvent(101, colours.green.dim),
    makeColourEvent(102, colours.green.dim),
  })
end

function TestDeliverSwitchMeter:testIsDarkWhenTimerIsOff()
  setUpMeter(twoBars, 3 * beat, true)
  deliverSwitchMeter()
  state.set("patternTimer", 0)
  local events = deliverSwitchMeter()
  lu.assertEquals(#events, 4)
  for index, event in ipairs(events) do
    lu.assertEquals(event, makeColourEvent(100 + index, off))
  end
end

function TestDeliverSwitchMeter:testIsDarkWhenLaunchEonIsNotFocused()
  setUpMeter(twoBars, 3 * beat, true)
  deliverSwitchMeter()
  remote.mock "get_item_state":impl(function()
    return { is_enabled = false, value = twoBars }
  end)
  setTransport({ items.patternTimer.index })
  lu.assertEquals(#deliverSwitchMeter(), 4)
  lu.assertEquals(state.get "patternTimer", 0)
end
