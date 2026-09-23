local test = require "test.lib._"
local lu = test.luaUnit
local items = require "src.lcxl3.config.items"
local state = require "src.lib.state._"
local setSelection = require "src.remote.setState.selection"

require "src.reason.codecs.novation.LCXL3"

TestSetStateSelection = {}

local reportSelection = test.reportSelection

function TestSetStateSelection:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
end

function TestSetStateSelection:testIsSelectingWhileTheSelectorIsMapped()
    reportSelection(0, 8, 1)
    lu.assertEquals(state.isSelecting(), true, "expected a device with a mapped selector to be a selecting device")
end

function TestSetStateSelection:testIsNotSelectingOnADeviceWithoutASelector()
    reportSelection(0, 8, 1)
    reportSelection(nil, 0, nil)
    lu.assertEquals(state.isSelecting(), false, "expected a device without a mapped selector not to be selecting")
    lu.assertEquals(state.getSelectedOption(), 0, "expected no option to be selected on a device that is not selecting")
end

function TestSetStateSelection:testSelectsTheOptionOfTheSelectorValue()
    reportSelection(2, 8, 3)
    lu.assertEquals(state.getSelectedOption(), 3, "expected selector value 2 to select the third option")
end

function TestSetStateSelection:testSelectsNoOptionWhileTheSelectorValueIsMinusOne()
    reportSelection(-1, 8, 0)
    lu.assertEquals(state.getSelectedOption(), 0, "expected selector value -1 to select no option")
end

function TestSetStateSelection:testLearnsTheOptionCountFromTheEnabledOptionSelectors()
    reportSelection(0, 4, 1)
    lu.assertEquals(state.getOptionCount(), 4, "expected a device with four bound option selectors to have four options")
end

function TestSetStateSelection:testAsksTheSurfaceForAReplyWhenTheMappingIsOutOfStep()
    -- the host reports pattern 3 selected while the group of pattern 1 is in force
    reportSelection(2, 8, 1)
    lu.assertEquals(state.consumeSelectionPing(), true, "expected a ping to be pending while the mapping is out of step")
end

function TestSetStateSelection:testDoesNotAskTheSurfaceWhenTheMappingIsInStep()
    reportSelection(2, 8, 3)
    lu.assertEquals(state.consumeSelectionPing(), false, "expected no ping while the mapping is in step")
end

function TestSetStateSelection:testAsksTheSurfaceOnlyOnceForTheSameSelection()
    reportSelection(2, 8, 1)
    state.consumeSelectionPing()
    reportSelection(2, 8, 1)
    lu.assertEquals(state.consumeSelectionPing(), false,
        "expected no second ping for a selection the surface has already been asked for")
end

function TestSetStateSelection:testAsksTheSurfaceAgainForANewSelection()
    reportSelection(2, 8, 1)
    state.consumeSelectionPing()
    reportSelection(5, 8, 1)
    lu.assertEquals(state.consumeSelectionPing(), true, "expected a new ping for a new selection")
end

function TestSetStateSelection:testDoesNotAskTheSurfaceOnADeviceWithoutASelector()
    reportSelection(nil, 0, nil)
    lu.assertEquals(state.consumeSelectionPing(), false, "expected no ping on a device that is not selecting")
end

function TestSetStateSelection:testIgnoresUnrelatedItems()
    reportSelection(2, 8, 3)
    remote.mock "get_item_state":impl(function()
        return { is_enabled = false, value = 0 }
    end)
    setSelection({ items.encoder1.index, items.pageSelect1.index })
    lu.assertEquals(state.isSelecting(), true, "expected unrelated items to leave the selection untouched")
    lu.assertEquals(state.getSelectedOption(), 3, "expected unrelated items to leave the selected option untouched")
end
