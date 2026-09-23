local test = require "test.lib._"
local lu = test.luaUnit
local items = require "src.lcxl3.config.items"
local state = require "src.lib.state._"
local processSelection = require "src.remote.processMidi.selection"

require "src.reason.codecs.novation.LCXL3"

TestProcessSelection = {}

local reportSelection = test.reportSelection

-- simulates the remote surface sending a CC, with the mocked remote.match_midi
-- matching on the pattern string alone
local function receive(pattern, value)
    remote.mock "match_midi":impl(function(midi)
        if midi == pattern then
            return { x = value }
        end
        return nil
    end)
    return processSelection({ time_stamp = 0 })
end

local function press(button)
    return receive(items[button].midi, 127)
end

local function handledInputs()
    local inputs = {}
    for _, call in ipairs(remote.mock "handle_input".calls) do
        table.insert(inputs, { item = call[1].item, value = call[1].value })
    end
    return inputs
end

function TestProcessSelection:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestProcessSelection:testPressingADimButtonSelectsItsOption()
    reportSelection(0, 8, 1)
    press "button10"
    lu.assertEquals(handledInputs(), { { item = items.selector.index, value = 1 } },
        "expected the second selection button to give the selector the value of the second option")
end

function TestProcessSelection:testPressingTheLitButtonDeselectsItsOption()
    reportSelection(0, 8, 1)
    press "button9"
    lu.assertEquals(handledInputs(), { { item = items.selector.index, value = -1 } },
        "expected pressing the button of the selected option to deselect it")
end

function TestProcessSelection:testPressingAButtonWhileNoOptionIsSelectedSelectsItsOption()
    reportSelection(-1, 8, 0)
    press "button11"
    lu.assertEquals(handledInputs(), { { item = items.selector.index, value = 2 } },
        "expected the third selection button to select the third option")
end

function TestProcessSelection:testShowsTheDisplayWithoutSelectingWhileShiftIsHeld()
    reportSelection(0, 8, 1)
    state.setShifted(true)
    press "button10"
    lu.assertEquals(handledInputs(), {}, "expected a press with Shift held not to change the selection")
    lu.assertEquals(state.isDisplayForced "button10", true, "expected a press with Shift held to show the display")
end

function TestProcessSelection:testConsumesTheReleaseWithoutChangingAnything()
    reportSelection(0, 8, 1)
    local processed = receive(items.button10.midi, 0)
    lu.assertEquals(processed, true, "expected the release of a selection button to be consumed")
    lu.assertEquals(handledInputs(), {}, "expected the release of a selection button not to change the selection")
end

function TestProcessSelection:testIgnoresButtonsBeyondTheOptionCount()
    reportSelection(0, 4, 1)
    local processed = press "button14"
    lu.assertEquals(processed, true, "expected a selection button without an option to be consumed")
    lu.assertEquals(handledInputs(), {}, "expected a selection button without an option to do nothing")
end

function TestProcessSelection:testLeavesTheButtonsToTheirParametersOnADeviceWithoutASelection()
    reportSelection(nil, 0, nil)
    local processed = press "button10"
    lu.assertEquals(processed, false, "expected the button to be left to the parameter it is mapped to")
    lu.assertEquals(handledInputs(), {}, "expected no input to be handled for a device that is not selecting")
end

function TestProcessSelection:testSwitchesTheMappingOnTheNextEventWhenOutOfStep()
    reportSelection(2, 8, 1)
    local processed = receive("b0 99 xx", 127)
    lu.assertEquals(handledInputs(), { { item = items.optionSelect3.index, value = 1 } },
        "expected any event to switch the mapping to the group of the selected option")
    lu.assertEquals(processed, false, "expected the event to be left to the other handlers")
end

function TestProcessSelection:testSwitchesToTheMappingOfNoOptionWhenDeselected()
    reportSelection(-1, 8, 3)
    receive("b0 99 xx", 127)
    lu.assertEquals(handledInputs(), { { item = items.noOptionSelect.index, value = 1 } },
        "expected the mapping to switch to the group of no option being selected")
end

function TestProcessSelection:testSwitchesTheMappingOnlyOnce()
    reportSelection(2, 8, 1)
    receive("b0 99 xx", 127)
    receive("b0 99 xx", 127)
    lu.assertEquals(#handledInputs(), 1,
        "expected the mapping to be switched once, not again before the host reports the switch")
end

function TestProcessSelection:testDoesNotSwitchTheMappingWhenInStep()
    reportSelection(2, 8, 3)
    receive("b0 99 xx", 127)
    lu.assertEquals(handledInputs(), {}, "expected no switch while the mapping is in step")
end

function TestProcessSelection:testSwitchesTheMappingBeforeHandlingAPress()
    reportSelection(2, 8, 1)
    press "button12"
    lu.assertEquals(handledInputs(), {
        { item = items.optionSelect3.index, value = 1 },
        { item = items.selector.index,      value = 3 },
    }, "expected the mapping to be brought in step before the press is handled")
end

function TestProcessSelection:testConsumesTheSurfacesReplyToTheQuery()
    reportSelection(2, 8, 1)
    local processed = receive("b6 1e xx", 2)
    lu.assertEquals(processed, true, "expected the surface's reply to the mode query to be consumed")
    lu.assertEquals(handledInputs(), { { item = items.optionSelect3.index, value = 1 } },
        "expected the reply to switch the mapping")
end

-- the whole round trip of a pattern clicked on the device's own panel, through
-- the codec's entry points: the host reports the new selection, the delivery
-- queries the surface, and the surface's reply switches the mapping
function TestProcessSelection:testFollowsASelectionMadeOnTheDevicesPanel()
    reportSelection(0, 8, 1)
    remote_deliver_midi(nil, 1)
    remote.clearMocks()

    -- pattern 4 is clicked on the panel; the group of pattern 1 is still in force
    reportSelection(3, 8, 1)
    local events = remote_deliver_midi(nil, 1)
    local queried = false
    for _, event in ipairs(events) do
        queried = queried or event == "b7 1e 00"
    end
    lu.assertEquals(queried, true, "expected the delivery to query the surface")

    remote.mock "match_midi":impl(function(midi)
        return midi == "b6 1e xx" and { x = 2 } or nil
    end)
    local processed = remote_process_midi({ time_stamp = 0 })
    lu.assertEquals(processed, true, "expected the surface's reply to be consumed")
    lu.assertEquals(handledInputs(), { { item = items.optionSelect4.index, value = 1 } },
        "expected the reply to switch the mapping to the group of pattern 4")
end
