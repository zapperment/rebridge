local test = require "test.lib._"
local lu = test.luaUnit
local isSwitchPoint = require "src.lppmk3.lib.timing.isSwitchPoint"

TestIsSwitchPoint = {}

-- a switch interval of 4 bars, with bars 100 units long; bar n starts at
-- (n - 1) * 100, so the grid lines are at the starts of bars 1, 5, 9…
local bar = 100
local interval = 4 * bar

local function startOfBar(n)
  return (n - 1) * bar
end

function TestIsSwitchPoint:testMovingForwardAcrossGridLine()
  lu.assertTrue(isSwitchPoint(startOfBar(5) - 1, startOfBar(5) + 1, interval))
end

function TestIsSwitchPoint:testMovingForwardOntoGridLine()
  lu.assertTrue(isSwitchPoint(startOfBar(5) - 1, startOfBar(5), interval))
end

function TestIsSwitchPoint:testMovingForwardAwayFromGridLine()
  lu.assertFalse(isSwitchPoint(startOfBar(5), startOfBar(5) + 1, interval))
end

function TestIsSwitchPoint:testMovingForwardWithinInterval()
  lu.assertFalse(isSwitchPoint(startOfBar(2), startOfBar(4) + 99, interval))
end

function TestIsSwitchPoint:testStandingStill()
  lu.assertFalse(isSwitchPoint(startOfBar(5), startOfBar(5), interval))
end

-- loop from bar 3 to 7: jumping back to bar 3 is not a switch point, the next
-- one is bar 5
function TestIsSwitchPoint:testJumpingBackOffGrid()
  lu.assertFalse(isSwitchPoint(startOfBar(7) - 1, startOfBar(3), interval))
end

-- loop from bar 5 to 9: jumping back to bar 5 is a switch point
function TestIsSwitchPoint:testJumpingBackOntoGridLine()
  lu.assertTrue(isSwitchPoint(startOfBar(9) - 1, startOfBar(5), interval))
end

-- loop from bar 2 to 4: there never is a switch point
function TestIsSwitchPoint:testLoopWithinOneInterval()
  local position = startOfBar(2)
  for _ = 1, 3 do
    for next = position + 10, startOfBar(4) - 1, 10 do
      lu.assertFalse(isSwitchPoint(position, next, interval))
      position = next
    end
    lu.assertFalse(isSwitchPoint(position, startOfBar(2), interval))
    position = startOfBar(2)
  end
end
