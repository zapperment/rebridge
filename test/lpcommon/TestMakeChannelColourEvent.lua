local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lpcommon.config.constants"
local makeColourEvent = require "src.lpcommon.lib.midi.makeChannelColourEvent"

TestMakeChannelColourEvent = {}

function TestMakeChannelColourEvent:testDefaultsToStaticOnChannel1()
    lu.assertEquals(makeColourEvent(11, 127), "B0 0B 7F")
end

function TestMakeChannelColourEvent:testStaticUsesChannel1()
    lu.assertEquals(makeColourEvent(11, 5, const.colourBehaviour.static), "B0 0B 05")
end

function TestMakeChannelColourEvent:testFlashingUsesChannel2()
    lu.assertEquals(makeColourEvent(11, 5, const.colourBehaviour.flashing), "B1 0B 05")
end

function TestMakeChannelColourEvent:testPulsingUsesChannel3()
    lu.assertEquals(makeColourEvent(11, 5, const.colourBehaviour.pulsing), "B2 0B 05")
end
