local test = require "test.lib._"
local lu = test.luaUnit
local state = require "src.lib.state._"
local col = require "src.lib.colour._"

TestConditionalColours = {}

-- simulates the host reporting a parameter mapped to a control, which is what
-- puts the parameter's value into the state the conditionals are resolved
-- against
local function reportParam(control, param, hostValue)
    state.set(control .. ".param", param)
    state.set(control .. ".hostValue", hostValue)
    state.update(control .. ".param")
    state.update(control .. ".hostValue")
end

-- Mode is a cycle parameter, so its host value is a number
local function setMode(mode)
    reportParam("button1", "Mode1", mode)
end

-- Out is a toggle parameter, so its host value is stored as a boolean
-- (see src/remote/setState/buttons.lua)
local function setOut(out)
    reportParam("button8", "Out 1", out)
end

local function panColour()
    return col.getColourName("algoritm", "Pan 1", "green")
end

function TestConditionalColours:setUp()
    test.resetState()
    state.set("deviceType", "algoritm")
    state.update "deviceType"
end

function TestConditionalColours:testTakesTheColourOfTheModeWhileTheOutputIsOn()
    setOut(true)
    local modeColours = { [32] = "blue", [64] = "orange", [96] = "white", [127] = "red" }
    for mode, expected in pairs(modeColours) do
        setMode(mode)
        local errorMessage = "expected Pan 1 to take the colour of mode " .. mode
        lu.assertEquals(panColour(), expected, errorMessage)
    end
end

function TestConditionalColours:testStaysUnlitWhileTheOutputIsOff()
    setOut(false)
    for _, mode in ipairs({ 0, 32, 64, 96, 127 }) do
        setMode(mode)
        local errorMessage = "expected Pan 1 to stay unlit in mode " .. mode .. " while Out 1 is off"
        lu.assertEquals(panColour(), "black", errorMessage)
    end
end

function TestConditionalColours:testStaysUnlitWhileTheModuleIsOff()
    setOut(true)
    setMode(0)
    local errorMessage = "expected Pan 1 to stay unlit while the module is off"
    lu.assertEquals(panColour(), "black", errorMessage)
end

function TestConditionalColours:testFollowsTheOutputWhenItIsSwitched()
    setMode(64)
    setOut(true)
    lu.assertEquals(panColour(), "orange", "expected Pan 1 to be lit while Out 1 is on")
    setOut(false)
    lu.assertEquals(panColour(), "black", "expected Pan 1 to go unlit when Out 1 is switched off")
    setOut(true)
    lu.assertEquals(panColour(), "orange", "expected Pan 1 to light up again when Out 1 is switched back on")
end

function TestConditionalColours:testTakesTheColourOfTheModeWhileTheOutputIsUnknown()
    -- the host has not reported Out 1 yet, e.g. because no control is mapped to
    -- it: the override has nothing to say, so the mode decides on its own
    setMode(32)
    local errorMessage = "expected Pan 1 to take the colour of its mode while Out 1 has no value"
    lu.assertEquals(panColour(), "blue", errorMessage)
end

function TestConditionalColours:testLeavesParamsWithoutOverridesToTheirOwnDependency()
    setOut(false)
    reportParam("encoder1", "Level 1", 100)
    local errorMessage = "expected Level 1, which has no override, to keep the colour of its mode"
    setMode(96)
    lu.assertEquals(col.getColourName("algoritm", "Level 1", "green"), "white", errorMessage)
end

function TestConditionalColours:testFallsBackToTheControlsColourWithoutAValueToDependOn()
    local errorMessage = "expected Pan 1 to fall back to the control's colour while nothing it depends on is known"
    lu.assertEquals(panColour(), "green", errorMessage)
end

-- a control mapped to a parameter with more than one dependency has to be
-- refreshed when any of them changes, or its LED would keep the colour it had
-- before
function TestConditionalColours:testForcesAnUpdateOfTheControlWhenAnOverrideChanges()
    reportParam("encoder24", "Pan 1", 64)
    lu.assertEquals(state.hasChanged "encoder24.hostValue", false,
        "expected the control mapped to Pan 1 to be up to date to begin with")
    setOut(false)
    lu.assertEquals(state.hasChanged "encoder24.hostValue", true,
        "expected switching Out 1 to force an update of the control mapped to Pan 1")
end

function TestConditionalColours:testForcesAnUpdateOfTheControlWhenTheModeChanges()
    reportParam("encoder24", "Pan 1", 64)
    setMode(32)
    lu.assertEquals(state.hasChanged "encoder24.hostValue", true,
        "expected changing Mode1 to force an update of the control mapped to Pan 1")
end
