local test = require "test.lib._"
local lu = test.luaUnit
local disp = require "src.lcxl3.lib.display._"

TestDisplayNames = {}

function TestDisplayNames:setUp()
    test.resetState()
end

function TestDisplayNames:testStripsThePatternFromABasslineGeneratorParameter()
    local result = disp.getDisplayName("bassline", "Pattern 3 OnBeat Source")
    lu.assertEquals(result, "OnBeat Source", "expected the pattern prefix to be dropped from the display name")
end

function TestDisplayNames:testStripsThePatternWhateverItsNumber()
    lu.assertEquals(disp.getDisplayName("bassline", "Pattern 1 Steps"), "Steps")
    lu.assertEquals(disp.getDisplayName("bassline", "Pattern 8 Steps"), "Steps")
end

function TestDisplayNames:testLeavesAParameterWithoutAPatternAlone()
    local result = disp.getDisplayName("bassline", "Playback Mode")
    lu.assertEquals(result, "Playback Mode", "expected a name without the pattern prefix to stay as it is")
end

function TestDisplayNames:testOnlyStripsAPrefix()
    local result = disp.getDisplayName("bassline", "Select Pattern 3 Now")
    lu.assertEquals(result, "Select Pattern 3 Now", "expected the pattern only to go from the start of the name")
end

function TestDisplayNames:testLeavesOtherDevicesAlone()
    local result = disp.getDisplayName("subtractor", "Pattern 3 OnBeat Source")
    lu.assertEquals(result, "Pattern 3 OnBeat Source", "expected a device without shortenings to keep the name")
end
