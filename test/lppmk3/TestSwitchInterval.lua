local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lppmk3.config.constants"
local switchInterval = require "src.lppmk3.lib.timing.switchInterval"

TestSwitchInterval = {}

function TestSwitchInterval:testHasNoIntervalWhenTimerIsOff()
  lu.assertNil(switchInterval(0))
end

function TestSwitchInterval:testIntervalsOfTimerValues()
  local bar = const.songPositionPerBar
  lu.assertEquals(switchInterval(1), bar / 4)
  lu.assertEquals(switchInterval(2), bar / 2)
  lu.assertEquals(switchInterval(3), bar)
  lu.assertEquals(switchInterval(4), 2 * bar)
  lu.assertEquals(switchInterval(5), 4 * bar)
end
