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

-- Ripley's delay time parameters have a list of conditionals: Delay Tempo Sync
-- decides between the plain and the synced time, Dual Delay between the single
-- time and the separate times for the left and the right channel, so that
-- exactly one of the four is displayed at a time
local function setRipleySwitches(delayTempoSync, dualDelay)
  state.set("button10.param", "Delay Tempo Sync")
  state.set("button10.hostValue", delayTempoSync)
  state.update "button10.param"
  state.update "button10.hostValue"
  state.set("button12.param", "Dual Delay")
  state.set("button12.hostValue", dualDelay)
  state.update "button12.param"
  state.update "button12.hostValue"
end

local function ripleyDisplays(param)
  return disp.shouldDisplay("ripley", param)
end

local function assertOnlyDisplays(displayed, errorMessage)
  local params = {
    "Delay Time", "Synced Time",
    "Delay Time L", "Synced Time L",
    "Delay Time R", "Synced Time R",
  }
  for _, param in ipairs(params) do
    local expected = false
    for _, displayedParam in ipairs(displayed) do
      if param == displayedParam then
        expected = true
      end
    end
    lu.assertEquals(
      ripleyDisplays(param),
      expected,
      errorMessage .. ", " .. param .. " should " .. (expected and "" or "not ") .. "display"
    )
  end
end

function TestShouldDisplay:testDisplaysThePlainDelayTimeWhileBothSwitchesAreOff()
  setRipleySwitches(false, false)
  assertOnlyDisplays(
    { "Delay Time" },
    "When neither delay tempo sync nor dual delay is turned on"
  )
end

function TestShouldDisplay:testDisplaysTheSyncedTimeWhileOnlyTempoSyncIsOn()
  setRipleySwitches(true, false)
  assertOnlyDisplays(
    { "Synced Time" },
    "When delay tempo sync is turned on and dual delay is turned off"
  )
end

function TestShouldDisplay:testDisplaysBothChannelTimesWhileOnlyDualDelayIsOn()
  setRipleySwitches(false, true)
  assertOnlyDisplays(
    { "Delay Time L", "Delay Time R" },
    "When delay tempo sync is turned off and dual delay is turned on"
  )
end

function TestShouldDisplay:testDisplaysBothSyncedChannelTimesWhileBothSwitchesAreOn()
  setRipleySwitches(true, true)
  assertOnlyDisplays(
    { "Synced Time L", "Synced Time R" },
    "When both delay tempo sync and dual delay are turned on"
  )
end

function TestShouldDisplay:testShouldDisplayWhenOneOfSeveralConditionalsHasNoValueYet()
  -- only one of the two parameters Delay Time depends on has been reported by
  -- the host, and that one does not replace it
  state.set("button10.param", "Delay Tempo Sync")
  state.set("button10.hostValue", false)
  state.update "button10.param"
  state.update "button10.hostValue"
  local result = ripleyDisplays("Delay Time")
  local errorMessage =
      "When the value of one of the parameters a param depends on is unknown, param should display"
  lu.assertEquals(result, true, errorMessage)
end

function TestShouldDisplay:testShouldNotDisplayWhenTheKnownOfSeveralConditionalsReplacesIt()
  -- Dual Delay has not been reported by the host, but Delay Tempo Sync alone
  -- already replaces Delay Time with Synced Time
  state.set("button10.param", "Delay Tempo Sync")
  state.set("button10.hostValue", true)
  state.update "button10.param"
  state.update "button10.hostValue"
  local result = ripleyDisplays("Delay Time")
  local errorMessage =
      "When one of the parameters a param depends on replaces it, param should not display"
  lu.assertEquals(result, false, errorMessage)
end
