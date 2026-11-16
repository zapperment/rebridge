local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lpcommon.config.constants"
local colours = require "src.lpcommon.lib.colour.config"
local makeColourEvent = require "src.lpm.lib.midi.makeColourEvent"

-- A light of the Launchpad Mini is set by the message of its pad or
-- button, with the velocity 16 x green + red + flags; the flags say which of
-- the surface's two copies of its LEDs the light is written to.
TestMakeColourEventLPM = {}

local flashing = const.colourBehaviour.flashing
local pulsing = const.colourBehaviour.pulsing

-- the values the programmer's reference gives for normal use
function TestMakeColourEventLPM:testStaticColoursAreWrittenToBothCopies()
  lu.assertEquals(makeColourEvent(81, colours.off), "90 00 0C")
  lu.assertEquals(makeColourEvent(81, colours.red.dim), "90 00 0D")
  lu.assertEquals(makeColourEvent(81, colours.red.vibrant), "90 00 0F")
  lu.assertEquals(makeColourEvent(81, colours.yellow.dim), "90 00 1D")
  lu.assertEquals(makeColourEvent(81, colours.yellow.vibrant), "90 00 3F")
  lu.assertEquals(makeColourEvent(81, colours.green.dim), "90 00 1C")
  lu.assertEquals(makeColourEvent(81, colours.green.vibrant), "90 00 3C")
  lu.assertEquals(makeColourEvent(81, colours.green.vibrant, const.colourBehaviour.static), "90 00 3C")
end

function TestMakeColourEventLPM:testALightGoesToTheAddressOfItsPlace()
  lu.assertEquals(makeColourEvent(11, colours.red.vibrant), "90 70 0F")
  lu.assertEquals(makeColourEvent(19, colours.red.vibrant), "90 78 0F")
  lu.assertEquals(makeColourEvent(91, colours.red.vibrant), "B0 68 0F")
  lu.assertEquals(makeColourEvent(98, colours.red.vibrant), "B0 6F 0F")
end

-- written to one copy only, a flashing light alternates with what the LED
-- showed, as on the later Launchpads
function TestMakeColourEventLPM:testAFlashingColourIsWrittenToOneCopy()
  lu.assertEquals(makeColourEvent(81, colours.green.vibrant, flashing), "90 00 30")
  lu.assertEquals(makeColourEvent(81, colours.red.vibrant, flashing), "90 00 03")
end

-- the surface cannot pulse: the light alternates with dark instead, with the
-- values the programmer's reference gives for flashing LEDs
function TestMakeColourEventLPM:testAPulsingColourFlashesWithDark()
  lu.assertEquals(makeColourEvent(81, colours.red.vibrant, pulsing), "90 00 0B")
  lu.assertEquals(makeColourEvent(81, colours.yellow.vibrant, pulsing), "90 00 3B")
  lu.assertEquals(makeColourEvent(81, colours.green.vibrant, pulsing), "90 00 38")
end

function TestMakeColourEventLPM:testAPlaceTheSurfaceHasNothingAtGetsNoEvent()
  lu.assertNil(makeColourEvent(99, colours.red.vibrant))
  lu.assertNil(makeColourEvent(1, colours.red.vibrant))
end
