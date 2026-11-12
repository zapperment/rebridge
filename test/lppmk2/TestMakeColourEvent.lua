local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lppmk2.config.constants"
local makeColourEvent = require "src.lppmk2.lib.midi.makeColourEvent"

-- in programmer layout the Launchpad Pro [MK2] takes its colours by SysEx
-- message: 0Ah for static, 23h for flashing and 28h for pulsing, each
-- followed by the LED and the colour
TestMakeColourEventMK2 = {}

function TestMakeColourEventMK2:testDefaultsToStatic()
  lu.assertEquals(makeColourEvent(11, 127), "f0 00 20 29 02 10 0A 0B 7F f7")
end

function TestMakeColourEventMK2:testStatic()
  lu.assertEquals(makeColourEvent(11, 5, const.colourBehaviour.static), "f0 00 20 29 02 10 0A 0B 05 f7")
end

function TestMakeColourEventMK2:testFlashing()
  lu.assertEquals(makeColourEvent(11, 5, const.colourBehaviour.flashing), "f0 00 20 29 02 10 23 0B 05 f7")
end

function TestMakeColourEventMK2:testPulsing()
  lu.assertEquals(makeColourEvent(11, 5, const.colourBehaviour.pulsing), "f0 00 20 29 02 10 28 0B 05 f7")
end

-- the LED on the front edge, which shows the mode colour, is 99
function TestMakeColourEventMK2:testLightsTheLedOnTheFrontEdge()
  lu.assertEquals(makeColourEvent(99, 3), "f0 00 20 29 02 10 0A 63 03 f7")
end
