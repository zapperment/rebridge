local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lpcommon.config.constants"
local makeColourEvent = require "src.lpmk2.lib.midi.makeColourEvent"

-- A light of the Launchpad MK2 is set by the message of its pad or button,
-- with a palette entry as its velocity or value, on the channel of its
-- behaviour.
TestMakeColourEventLPMK2 = {}

local static = const.colourBehaviour.static
local flashing = const.colourBehaviour.flashing
local pulsing = const.colourBehaviour.pulsing

-- the examples of the programmer's reference: the top left pad in blue, and
-- the cursor left button in pink
function TestMakeColourEventLPMK2:testPadsAndSceneButtonsAreLitByNotes()
  lu.assertEquals(makeColourEvent(81, 45), "90 51 2D")
  lu.assertEquals(makeColourEvent(81, 45, static), "90 51 2D")
  lu.assertEquals(makeColourEvent(19, 5), "90 13 05")
  lu.assertEquals(makeColourEvent(89, 5), "90 59 05")
end

function TestMakeColourEventLPMK2:testTheTopRowIsLitByControlChanges()
  lu.assertEquals(makeColourEvent(93, 53), "B0 6A 35")
  lu.assertEquals(makeColourEvent(91, 5), "B0 68 05")
  lu.assertEquals(makeColourEvent(98, 5), "B0 6F 05")
end

function TestMakeColourEventLPMK2:testOffIsColour0()
  lu.assertEquals(makeColourEvent(11, 0), "90 0B 00")
end

-- the examples of the programmer's reference: the bottom left pad flashing
-- red, and the top right pad pulsing purple
function TestMakeColourEventLPMK2:testFlashingIsOnChannel2()
  lu.assertEquals(makeColourEvent(11, 5, flashing), "91 0B 05")
  lu.assertEquals(makeColourEvent(95, 5, flashing), "B1 6C 05")
end

function TestMakeColourEventLPMK2:testPulsingIsOnChannel3()
  lu.assertEquals(makeColourEvent(88, 81, pulsing), "92 58 51")
  lu.assertEquals(makeColourEvent(95, 81, pulsing), "B2 6C 51")
end

function TestMakeColourEventLPMK2:testAPlaceTheSurfaceHasNothingAtGetsNoEvent()
  lu.assertNil(makeColourEvent(99, 5))
  lu.assertNil(makeColourEvent(1, 5))
end
