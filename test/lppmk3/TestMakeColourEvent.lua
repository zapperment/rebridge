local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lppmk3.config.constants"
local makeColourEvent = require "src.lppmk3.lib.midi.makeColourEvent"

TestMakeColourEvent = {}

function TestMakeColourEvent:testDefaultsToStaticOnChannel1()
    lu.assertEquals(makeColourEvent(11, 127), "B0 0B 7F")
end

function TestMakeColourEvent:testStaticUsesChannel1()
    lu.assertEquals(makeColourEvent(11, 5, const.colourBehaviour.static), "B0 0B 05")
end

function TestMakeColourEvent:testFlashingUsesChannel2()
    lu.assertEquals(makeColourEvent(11, 5, const.colourBehaviour.flashing), "B1 0B 05")
end

function TestMakeColourEvent:testPulsingUsesChannel3()
    lu.assertEquals(makeColourEvent(11, 5, const.colourBehaviour.pulsing), "B2 0B 05")
end
