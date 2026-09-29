local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lppmk3.config.constants"
local ctrl = require "src.lppmk3.config.controls"
local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"
local setPatterns = require "src.lppmk3.remote.setState.patterns"
local setTransport = require "src.lppmk3.remote.setState.transport"
local defineItemIndices = require "test.lppmk3.defineItemIndices"

TestSetStateTiming = {}

local bar = const.songPositionPerBar

-- the timer values for 1 and 4 bars
local oneBar = 3
local fourBars = 5

local function startOfBar(n)
  return (n - 1) * bar
end

-- simulates the host reporting the given items with the given values, as
-- remote_set_state does
local function report(values)
  local changedItems = {}
  local itemStates = {}
  for name, value in pairs(values) do
    table.insert(changedItems, items[name].index)
    itemStates[items[name].index] = { is_enabled = true, value = value }
  end
  remote.mock "get_item_state":impl(function(index)
    return itemStates[index]
  end)
  setPatterns(changedItems)
  setTransport(changedItems)
end

-- simulates the host giving remote focus to the LaunchEon of the given name
local function focus(launchEon)
  remote.mock "is_item_enabled":impl(function(index)
    return index == items.deviceName.index
  end)
  remote.mock "get_item_text_value":impl(function(index)
    if index == items.deviceName.index then
      return launchEon
    end
  end)
end

local function startPlaying(timer)
  report { patternTimer = timer, playButton = 1, songPosition = startOfBar(1) }
end

function TestSetStateTiming:setUp()
  remote.clearMocks()
  -- no LaunchEon has remote focus, unless a test gives it
  remote.mock "is_item_enabled":reset()
  remote.mock "get_item_text_value":reset()
  defineItemIndices()
  state.set("patternTimer", 0)
  state.set("transport.playing", false)
  state.set("songPosition", nil)
  state.set("launchEon", nil)
  for _, device in ipairs(ctrl.devices) do
    state.set(device .. ".enabled", false)
    state.set(device .. ".hostValue", 0)
    state.set(device .. ".playingValue", 0)
  end
  report { device1 = 3, device2 = 5 }
end

function TestSetStateTiming:testPatternPlaysAtOnceWhenDeviceIsMadeActive()
  lu.assertEquals(state.get "device1.playingValue", 3)
end

function TestSetStateTiming:testPatternPlaysAtOnceWhenDeviceIsMadeActiveWhilePlaying()
  state.set("device1.enabled", false)
  startPlaying(fourBars)
  report { device1 = 6 }
  lu.assertEquals(state.get "device1.playingValue", 6)
end

function TestSetStateTiming:testPatternPlaysAtOnceWhileStopped()
  report { patternTimer = fourBars }
  report { device1 = 4 }
  lu.assertEquals(state.get "device1.playingValue", 4)
end

function TestSetStateTiming:testPatternPlaysAtOnceWhileTimerIsOff()
  startPlaying(0)
  report { device1 = 4 }
  lu.assertEquals(state.get "device1.playingValue", 4)
end

function TestSetStateTiming:testPatternIsPendingWhilePlayingWithTimer()
  startPlaying(fourBars)
  report { device1 = 4 }
  lu.assertEquals(state.get "device1.hostValue", 4)
  lu.assertEquals(state.get "device1.playingValue", 3)
end

function TestSetStateTiming:testPendingPatternsPlayAtSwitchPoint()
  startPlaying(fourBars)
  report { device1 = 4, device2 = 0 }
  report { songPosition = startOfBar(4) }
  lu.assertEquals(state.get "device1.playingValue", 3)
  report { songPosition = startOfBar(5) + 10 }
  lu.assertEquals(state.get "device1.playingValue", 4)
  lu.assertEquals(state.get "device2.playingValue", 0)
end

function TestSetStateTiming:testSwitchPointFollowsCurrentTimer()
  startPlaying(fourBars)
  report { songPosition = startOfBar(2) + 10 }
  report { device1 = 4 }
  report { patternTimer = oneBar }
  report { songPosition = startOfBar(3) + 10 }
  lu.assertEquals(state.get "device1.playingValue", 4)
end

function TestSetStateTiming:testPendingPatternsPlayWhenTransportStops()
  startPlaying(fourBars)
  report { device1 = 4, device2 = 1 }
  report { playButton = 0 }
  lu.assertEquals(state.get "device1.playingValue", 4)
  lu.assertEquals(state.get "device2.playingValue", 1)
end

function TestSetStateTiming:testPendingPatternsPlayWhenTimerIsTurnedOff()
  startPlaying(fourBars)
  report { device1 = 4 }
  report { patternTimer = 0 }
  lu.assertEquals(state.get "device1.playingValue", 4)
end

function TestSetStateTiming:testJumpBackOffGridIsNoSwitchPoint()
  startPlaying(fourBars)
  report { songPosition = startOfBar(6) }
  report { device1 = 4 }
  report { songPosition = startOfBar(7) - 10 }
  report { songPosition = startOfBar(3) }
  lu.assertEquals(state.get "device1.playingValue", 3)
  report { songPosition = startOfBar(5) }
  lu.assertEquals(state.get "device1.playingValue", 4)
end

function TestSetStateTiming:testJumpBackOntoGridIsSwitchPoint()
  startPlaying(fourBars)
  report { songPosition = startOfBar(7) }
  report { device1 = 4 }
  report { songPosition = startOfBar(9) - 10 }
  report { songPosition = startOfBar(5) }
  lu.assertEquals(state.get "device1.playingValue", 4)
end

function TestSetStateTiming:testFirstSongPositionIsNoSwitchPoint()
  report { patternTimer = fourBars, playButton = 1 }
  report { device1 = 4 }
  report { songPosition = startOfBar(5) }
  lu.assertEquals(state.get "device1.playingValue", 3)
end

function TestSetStateTiming:testPatternIsPendingWhilePlayingWithTimerOnFocusedLaunchEon()
  focus "LaunchEon 1"
  report { device1 = 3 }
  startPlaying(fourBars)
  report { device1 = 4 }
  lu.assertEquals(state.get "device1.playingValue", 3)
end

function TestSetStateTiming:testPatternsOfAnotherLaunchEonPlayAtOnce()
  focus "LaunchEon 1"
  report { device1 = 3 }
  startPlaying(fourBars)
  focus "LaunchEon 2"
  report { device1 = 0, device8 = 1 }
  lu.assertEquals(state.get "device1.playingValue", 0)
  lu.assertEquals(state.get "device8.playingValue", 1)
end

function TestSetStateTiming:testPendingPatternOfPreviousLaunchEonIsNoLongerPending()
  focus "LaunchEon 1"
  report { device1 = 3 }
  startPlaying(fourBars)
  report { device2 = 6 }
  lu.assertEquals(state.get "device2.playingValue", 5)
  -- the other LaunchEon happens to have the same pattern selected, so the host
  -- does not report it
  focus "LaunchEon 2"
  report { device1 = 0 }
  lu.assertEquals(state.get "device2.playingValue", 6)
end
