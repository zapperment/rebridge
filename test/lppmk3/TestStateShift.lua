local test = require "test.lib._"
local lu = test.luaUnit
local StateManager = require "src.lppmk3.lib.state.StateManager"

TestStateShift = {}

function TestStateShift:setUp()
  self.state = StateManager:new()
end

function TestStateShift:testIsNotShiftedInitially()
  lu.assertFalse(self.state:isShifted())
end

function TestStateShift:testShiftAndUnshift()
  self.state:shift()
  lu.assertTrue(self.state:isShifted())
  self.state:unshift()
  lu.assertFalse(self.state:isShifted())
end

function TestStateShift:testSetShifted()
  self.state:setShifted(true)
  lu.assertTrue(self.state:isShifted())
  self.state:setShifted(false)
  lu.assertFalse(self.state:isShifted())
end

function TestStateShift:testSetShiftedIgnoresNonBooleans()
  self.state:setShifted(true)
  self.state:setShifted(nil)
  lu.assertTrue(self.state:isShifted())
  self.state:setShifted(0)
  lu.assertTrue(self.state:isShifted())
end

function TestStateShift:testInstancesDoNotShareShiftState()
  local other = StateManager:new()
  self.state:shift()
  lu.assertFalse(other:isShifted())
end
