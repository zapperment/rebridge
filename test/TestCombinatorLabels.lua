local test = require "test.lib._"
local lu = test.luaUnit
local combinatorLabels = require "src.config.combinatorLabels"
local const = require "src.lcxl3.config.constants"
local disp = require "src.lcxl3.lib.display._"
local hex = require "src.lib.hex._"
local items = require "src.lcxl3.config.items"
local state = require "src.lib.state._"
local deliverEncoders = require "src.remote.deliverMidi.encoders"
local setEncoders = require "src.remote.setState.encoders"
local setInfo = require "src.remote.setState.info"

require "src.reason.codecs.novation.LCXL3"

TestCombinatorLabels = {}

-- config/combinatorLabels is generated from whichever patch files the last run
-- of scripts/extractCombinatorLabels.js found, so these tests put their own
-- patches into it rather than relying on what happens to be in there
local PATCH = "Test Combi"
local DEVICE_NAME = "Test Combi In The Rack"
local OTHER_PATCH = "Other Test Combi"

local function paramNameEvent(name)
    return const.sysexHeader .. " 06 xx 00 " .. hex.textToHex(name) .. " f7"
end

local function contains(events, event)
    for _, candidate in ipairs(events) do
        if candidate == event then
            return true
        end
    end
    return false
end

-- simulates the host reporting the encoder as mapped to the given parameter
local function reportEncoder(encoder, paramName)
    remote.mock "get_item_state":impl(function()
        return { is_enabled = true, value = 64, remote_item_name = paramName, text_value = "64" }
    end)
    setEncoders({ items[encoder].index })
end

-- simulates the host reporting that another patch has been loaded
local function reportPatchName(patchName)
    remote.mock "get_item_text_value":impl(function()
        return patchName
    end)
    setInfo({ items.patchName.index })
end

function TestCombinatorLabels:setUp()
    test.resetState()
    remote.clearMocks()
    remote_init()
    combinatorLabels[PATCH] = {
        ["Rotary 1"] = "RELEASE",
        ["Button 1"] = "Switch 1",
    }
    combinatorLabels[DEVICE_NAME] = combinatorLabels[PATCH]
    combinatorLabels[OTHER_PATCH] = {
        ["Rotary 1"] = "DECAY",
    }
end

function TestCombinatorLabels:tearDown()
    combinatorLabels[PATCH] = nil
    combinatorLabels[DEVICE_NAME] = nil
    combinatorLabels[OTHER_PATCH] = nil
end

function TestCombinatorLabels:testKeepsTheParameterNameOfADeviceThatIsNotACombinator()
    state.set("patchName", PATCH)
    local result = disp.getDisplayName("subtractor", "Rotary 1")
    local errorMessage = "only a Combinator has labels, so any other device keeps its parameter name"
    lu.assertEquals(result, "Rotary 1", errorMessage)
end

function TestCombinatorLabels:testUsesTheLabelThePatchGivesTheRotary()
    state.set("patchName", PATCH)
    local result = disp.getDisplayName("combinator", "Rotary 1")
    local errorMessage = "expected the rotary to be shown under the label the patch gives it"
    lu.assertEquals(result, "RELEASE", errorMessage)
end

function TestCombinatorLabels:testUsesTheLabelThePatchGivesTheButton()
    state.set("patchName", PATCH)
    local result = disp.getDisplayName("combinator", "Button 1")
    local errorMessage = "expected the button to be shown under the label the patch gives it"
    lu.assertEquals(result, "Switch 1", errorMessage)
end

function TestCombinatorLabels:testKeepsTheParameterNameOfASlotThePatchDidNotLabel()
    state.set("patchName", PATCH)
    local result = disp.getDisplayName("combinator", "Rotary 2")
    local errorMessage = "a slot the patch left alone has no label, so it keeps its parameter name"
    lu.assertEquals(result, "Rotary 2", errorMessage)
end

function TestCombinatorLabels:testKeepsTheParameterNameOfAPatchItKnowsNothingAbout()
    state.set("patchName", "A Patch Nobody Has Extracted")
    local result = disp.getDisplayName("combinator", "Rotary 1")
    local errorMessage = "expected an unknown patch to leave the parameter name alone"
    lu.assertEquals(result, "Rotary 1", errorMessage)
end

function TestCombinatorLabels:testFallsBackToTheDeviceNameWhenThePatchNameIsUnknown()
    state.set("deviceName", DEVICE_NAME)
    local result = disp.getDisplayName("combinator", "Rotary 1")
    local errorMessage = "expected the labels to be found under the name of the device in the rack"
    lu.assertEquals(result, "RELEASE", errorMessage)
end

function TestCombinatorLabels:testPrefersThePatchNameOverTheDeviceName()
    state.set("patchName", OTHER_PATCH)
    state.set("deviceName", DEVICE_NAME)
    local result = disp.getDisplayName("combinator", "Rotary 1")
    local errorMessage = "the patch name is what Reason reports, so it has to win over the device name"
    lu.assertEquals(result, "DECAY", errorMessage)
end

function TestCombinatorLabels:testIgnoresTheWhitespaceReasonPadsTheNamesWith()
    state.set("patchName", " " .. PATCH .. " ")
    local result = disp.getDisplayName("combinator", "Rotary 1")
    local errorMessage = "expected the patch to be found although Reason padded its name"
    lu.assertEquals(result, "RELEASE", errorMessage)
end

function TestCombinatorLabels:testSendsTheLabelToTheEncodersDisplay()
    state.set("deviceType", "combinator")
    state.set("patchName", PATCH)
    reportEncoder("encoder1", "Rotary 1")
    local events = deliverEncoders()
    local errorMessage = "expected the encoder's display to show the label rather than \"Rotary 1\""
    lu.assertEquals(contains(events, paramNameEvent "RELEASE"), true, errorMessage)
    errorMessage = "expected the parameter name Reason reports not to be sent"
    lu.assertEquals(contains(events, paramNameEvent "Rotary 1"), false, errorMessage)
end

function TestCombinatorLabels:testSendsNoNameAgainWhileTheSamePatchStaysLoaded()
    state.set("deviceType", "combinator")
    state.set("patchName", PATCH)
    reportEncoder("encoder1", "Rotary 1")
    deliverEncoders()
    local events = deliverEncoders()
    local errorMessage = "a name is only sent once it has changed, so nothing should be sent again"
    lu.assertEquals(contains(events, paramNameEvent "RELEASE"), false, errorMessage)
end

function TestCombinatorLabels:testSendsTheNewLabelsWhenAnotherPatchIsLoaded()
    state.set("deviceType", "combinator")
    state.set("patchName", PATCH)
    reportEncoder("encoder1", "Rotary 1")
    deliverEncoders()
    -- the Combinator goes on calling the parameter "Rotary 1", so the labels of
    -- the patch just loaded only reach the display because the patch name
    -- changing forces the names to be sent again
    reportPatchName(OTHER_PATCH)
    local events = deliverEncoders()
    local errorMessage = "expected the label of the patch just loaded to be sent to the display"
    lu.assertEquals(contains(events, paramNameEvent "DECAY"), true, errorMessage)
end
