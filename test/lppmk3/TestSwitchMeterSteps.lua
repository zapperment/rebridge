local test = require "test.lib._"
local lu = test.luaUnit
local switchMeterSteps = require "src.lppmk3.lib.timing.switchMeterSteps"

TestSwitchMeterSteps = {}

-- a switch interval of 2 bars, with beats 100 units long, so each step is one
-- beat long
local beat = 100
local interval = 8 * beat

function TestSwitchMeterSteps:testLightsFirstButtonDuringFirstStep()
  lu.assertEquals(switchMeterSteps(0, interval), 1)
  lu.assertEquals(switchMeterSteps(beat - 1, interval), 1)
end

function TestSwitchMeterSteps:testLightsOneMoreButtonPerStep()
  lu.assertEquals(switchMeterSteps(beat, interval), 2)
  lu.assertEquals(switchMeterSteps(2 * beat + 50, interval), 3)
end

function TestSwitchMeterSteps:testLightsWholeRowDuringLastStep()
  lu.assertEquals(switchMeterSteps(7 * beat, interval), 8)
  lu.assertEquals(switchMeterSteps(interval - 1, interval), 8)
end

function TestSwitchMeterSteps:testStartsOverWithNextInterval()
  lu.assertEquals(switchMeterSteps(interval, interval), 1)
  lu.assertEquals(switchMeterSteps(3 * interval + 5 * beat, interval), 6)
end
