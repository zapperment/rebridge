local test = require "test.lib._"
local lu = test.luaUnit
local disp = require "src.lib.display._"
local state = require "src.lib.state._"

TestShouldDisplay = {}

local function setDelaySync(delaySync)
  state.set("button1.param", "Delay Sync")
  state.set("button1.hostValue", delaySync)
  state.update "button1.param"
  state.update "button1.hostValue"
end

-- "Delay Sync" is a toggle param, so its host value is stored as a boolean
-- (see src/remote/setState/buttons.lua), which is what the conditionals
-- config compares against
local function turnDelaySyncOn()
  setDelaySync(true)
end

local function turnDelaySyncOff()
  setDelaySync(false)
end
function TestShouldDisplay:setUp()
  test.resetState()
end

function TestShouldDisplay:testShouldDisplayDelayTimeWhenDelaySyncIsTurnedOff()
  turnDelaySyncOff()
  local result = disp.shouldDisplay("algoritm", "Delay Time")
  local errorMessage = "When delay sync is turned off, delay time should display"
  lu.assertEquals(result, true, errorMessage)
end

function TestShouldDisplay:testShouldNotDisplayDelayTimeWhenDelaySyncIsTurnedOn()
  turnDelaySyncOn()
  local result = disp.shouldDisplay("algoritm", "Delay Time")
  local errorMessage = "When delay sync is turned on, delay time should not display"
  lu.assertEquals(result, false, errorMessage)
end

function TestShouldDisplay:testShouldDisplayDelaySyncedTimeWhenDelaySyncIsTurnedOn()
  turnDelaySyncOn()
  local result = disp.shouldDisplay("algoritm", "Delay Synced Time")
  local errorMessage = "When delay sync is turned on, delay synced time should display"
  lu.assertEquals(result, true, errorMessage)
end

function TestShouldDisplay:testShouldNotDisplayDelaySyncedTimeWhenDelaySyncIsTurnedOff()
  turnDelaySyncOff()
  local result = disp.shouldDisplay("algoritm", "Delay Synced Time")
  local errorMessage = "When delay sync is turned off, delay synced time should not display"
  lu.assertEquals(result, false, errorMessage)
end

function TestShouldDisplay:testShouldDisplayWhenDeviceHasNoConditional()
  local result = disp.shouldDisplay("someDevice", "Some Param")
  local errorMessage = "When display has no conditional configuration, param should display"
  lu.assertEquals(result, true, errorMessage)
end

function TestShouldDisplay:testShouldDisplayWhenParamHasNoConditional()
  local result = disp.shouldDisplay("algoritm", "Some Param")
  local errorMessage = "When param has no conditional configuration, param should display"
  lu.assertEquals(result, true, errorMessage)
end

function TestShouldDisplay:testShouldDisplayWhenParamHasNoUseOtherParamWhenValue()
  local result = disp.shouldDisplay("algoritm", "Out 1")
  local errorMessage = "When param is not configured to use other param for certain values, param should display"
  lu.assertEquals(result, true, errorMessage)
end
