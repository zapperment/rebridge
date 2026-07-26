local test = require("test.lib._")
local lu = test.luaUnit
local state = require("src.lib.state._")

TestStateManagement = {}

function TestStateManagement:setUp()
    test.resetState()
end

function TestStateManagement:testChangingTheStateWithSetAndUpdating()
    local current, next, hasChanged, updated, errorMessage
    state.set("encoder1.value", 127)
    current = state.get("encoder1.value")
    next = state.getNext("encoder1.value")
    hasChanged = state.hasChanged("encoder1.value")
    errorMessage = "after setting the state to 127, the current state should still be 0, but it is " ..
        tostring(current)
    lu.assertEquals(current, 0, errorMessage)
    errorMessage = "after setting the state to 127, the next state should now be 127, but it is " .. tostring(next)
    lu.assertEquals(next, 127, errorMessage)
    errorMessage = "after setting the state, 'hasChanged' should be true, but it is " .. tostring(hasChanged)
    lu.assertEquals(hasChanged, true, errorMessage)
    updated = state.update("encoder1.value")
    current = state.get("encoder1.value")
    next = state.getNext("encoder1.value")
    hasChanged = state.hasChanged("encoder1.value")
    errorMessage =
        "after setting the state to 127, calling 'update' should return the new current state 127, but it returned " ..
        tostring(updated)
    lu.assertEquals(updated, 127, errorMessage)
    errorMessage =
        "after setting the state to 127 and calling 'update', the current state should now be 127, but it is " ..
        tostring(current)
    lu.assertEquals(current, 127, errorMessage)
    errorMessage =
        "after setting the state to 127 and calling 'update', the next state should still be 127, but it is " ..
        tostring(next)
    lu.assertEquals(next, 127, errorMessage)
    errorMessage = "after setting the state and calling 'update', 'hasChanged' should be false, but it is " ..
        tostring(hasChanged)
    lu.assertEquals(hasChanged, false, errorMessage)
end

function TestStateManagement:testChangingTheStateWithInc()
    lu.assertEquals(state.get("encoder1.value"), 0, "nope")
    local next
    state.inc("encoder1.value")
    next = state.getNext("encoder1.value")
    local errorMessage = "after changing the state with 'inc', expected the next value to be 1, but it is " ..
        tostring(next)
    lu.assertEquals(next, 1, errorMessage)
end

function TestStateManagement:testMaximumValueForDecIs127()
    local next
    state.set("encoder1.value", 127)
    state.update("encoder1.value")
    state.inc("encoder1.value")
    state.update("encoder1.value")
    state.inc("encoder1.value")
    state.update("encoder1.value")
    state.inc("encoder1.value")
    next = state.getNext("encoder1.value")
    local errorMessage = "after increasing the state several times, beyond the maximum value of 127, " ..
        "expected the next value to be 127, but it is " .. tostring(next)
    lu.assertEquals(next, 127, errorMessage)
end

function TestStateManagement:testChangingTheStateWithDec()
    local next
    state.set("encoder1.value", 127)
    state.update("encoder1.value")
    state.dec("encoder1.value")
    next = state.getNext("encoder1.value")
    local errorMessage = "after changing the state with 'dec', expected the next value to be 126, but it is " ..
        tostring(next)
    lu.assertEquals(next, 126, errorMessage)
end

function TestStateManagement:testMinimumValueForDecIs0()
    local next
    state.dec("encoder1.value")
    state.update("encoder1.value")
    state.dec("encoder1.value")
    state.update("encoder1.value")
    state.dec("encoder1.value")
    next = state.getNext("encoder1.value")
    local errorMessage = "after decreasing the state several times, beyond the minimum value of 0, " ..
        "expected the next value to be 0, but it is " .. tostring(next)
    lu.assertEquals(next, 0, errorMessage)
end

function TestStateManagement:testAddAndSubtract()
    local value, errorMessage
    state.add("encoder1.value", 20)
    value = state.update("encoder1.value")
    errorMessage = "after adding 20 using 'add', 'update' returned an incorrect value"
    lu.assertEquals(value, 20, errorMessage)
    state.add("encoder1.value", 20, 0, 30)
    value = state.update("encoder1.value")
    errorMessage =
    "after adding 20 to 30 using 'add', while the maximum value is 30, 'update' returned an incorrect value"
    lu.assertEquals(value, 30, errorMessage)
    state.add("encoder1.value", -40, 0, 30)
    value = state.update("encoder1.value")
    errorMessage =
    "after adding -40 to 30 using 'add', while the minimum value is 0, 'update' returned an incorrect value"
    lu.assertEquals(value, 0, errorMessage)
    state.add("encoder1.value", -1)
    value = state.update("encoder1.value")
    errorMessage = "after adding -1 to 0 using 'add', 'update' returned an incorrect value"
    lu.assertEquals(value, -1, errorMessage)
    state.add("encoder1.value", 1001)
    value = state.update("encoder1.value")
    errorMessage = "after adding 1001 to -1 using 'add', 'update' returned an incorrect value"
    lu.assertEquals(value, 1000)
end

function TestStateManagement:testFlip()
    local value, errorMessage
    state.flip("encoder1.enabled")
    value = state.update("encoder1.enabled")
    errorMessage = "after calling 'flip' on a state with value 'false', 'update' returned an incorrect value"
    lu.assertEquals(value, true, errorMessage)
    state.flip("encoder1.enabled")
    value = state.update("encoder1.enabled")
    errorMessage = "after calling 'flip' on a state with value 'true', 'update' returned an incorrect value"
    lu.assertEquals(value, false, errorMessage)
end
