local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lpcommon.config.constants"
local shift = require "src.lpcommon.lib.state._"
local surface = require "src.lpcommon.lib.surface._"

-- The Shift layer on its own, for a made-up device: with Shift held, place 1
-- is control 101, place 2 is nothing, and place 3 is as ever.
TestShiftLayer = {}

local makeLight = surface.makeLight
local flashing = const.colourBehaviour.flashing
local pulsing = const.colourBehaviour.pulsing

-- a colour event says where it goes, in which colour and how
local function makeColourEvent(place, colour, behaviour)
  return place .. ":" .. colour .. (behaviour and ":" .. behaviour or "")
end

local device = {
  controls = { shiftLayer = { [1] = 101, [2] = false } },
  midi = { makeColourEvent = makeColourEvent },
}
local layer = surface.makeShiftLayer(device)

function TestShiftLayer:setUp()
  shift.setShifted(false)
  layer.reset()
end

function TestShiftLayer:tearDown()
  shift.setShifted(false)
end

function TestShiftLayer:testIsOneForEachDevice()
  lu.assertIs(surface.makeShiftLayer(device), layer)
  local other = { controls = {}, midi = device.midi }
  lu.assertNotIs(surface.makeShiftLayer(other), layer)
end

function TestShiftLayer:testWithoutShiftAPlaceIsItsOwnControl()
  lu.assertEquals(layer.translate(1, 127), 1)
  lu.assertEquals(layer.translate(2, 127), 2)
  lu.assertEquals(layer.translate(3, 127), 3)
end

function TestShiftLayer:testWithShiftAPlaceIsItsControlOfTheShiftLayer()
  shift.setShifted(true)
  lu.assertEquals(layer.translate(1, 127), 101)
  lu.assertIsFalse(layer.translate(2, 127))
  lu.assertEquals(layer.translate(3, 127), 3)
end

function TestShiftLayer:testWhatIsLetGoIsWhatWasPressed()
  layer.translate(1, 127)
  shift.setShifted(true)
  lu.assertEquals(layer.translate(1, 0), 1)
  layer.translate(1, 127)
  layer.translate(2, 127)
  shift.setShifted(false)
  lu.assertEquals(layer.translate(1, 0), 101)
  lu.assertIsFalse(layer.translate(2, 0))
  -- once let go, it is pressed as what it is by then
  lu.assertEquals(layer.translate(1, 127), 1)
end

function TestShiftLayer:testLettingGoOfWhatWasNotPressedGoesByShift()
  lu.assertEquals(layer.translate(1, 0), 1)
  shift.setShifted(true)
  lu.assertEquals(layer.translate(1, 0), 101)
end

function TestShiftLayer:testADeviceWithoutAShiftLayerDeliversEveryLight()
  local plain = surface.makeShiftLayer({ controls = {}, midi = device.midi })
  shift.setShifted(true)
  lu.assertEquals(plain.translate(1, 127), 1)
  lu.assertEquals(plain.deliver({ makeLight(1, 5), makeLight(3, 6, pulsing) }), { "1:5", "3:6:" .. pulsing })
  lu.assertEquals(plain.deliver({}), {})
end

function TestShiftLayer:testWithoutShiftOnlyTheLightsOfThePlacesOwnControlsAreDelivered()
  lu.assertEquals(layer.deliver({ makeLight(1, 5), makeLight(101, 6), makeLight(3, 7) }), { "1:5", "3:7" })
end

function TestShiftLayer:testWithShiftTheLightsOfTheShiftLayerAreDeliveredToTheirPlaces()
  shift.setShifted(true)
  layer.deliver({})
  lu.assertEquals(layer.deliver({ makeLight(1, 5), makeLight(101, 6), makeLight(3, 7) }), { "1:6", "3:7" })
end

function TestShiftLayer:testPressingShiftBringsTheShiftLayerIntoSight()
  layer.deliver({ makeLight(1, 5), makeLight(2, 8), makeLight(101, 6), makeLight(3, 7) })
  shift.setShifted(true)
  -- place 2 is dark while Shift is held; place 3 is not delivered again
  lu.assertEquals(layer.deliver({}), { "1:6", "2:0" })
  lu.assertEquals(layer.deliver({}), {})
end

function TestShiftLayer:testLettingGoOfShiftBringsBackWhatThePlacesShowed()
  layer.deliver({ makeLight(1, 5), makeLight(2, 8) })
  shift.setShifted(true)
  layer.deliver({})
  shift.setShifted(false)
  lu.assertEquals(layer.deliver({}), { "1:5", "2:8" })
end

function TestShiftLayer:testAControlThatHasNeverBeenLitIsDark()
  shift.setShifted(true)
  lu.assertEquals(layer.deliver({}), { "1:0", "2:0" })
  shift.setShifted(false)
  lu.assertEquals(layer.deliver({}), { "1:0", "2:0" })
end

-- a light that changes as Shift is pressed or let go is delivered once, as
-- it is by then
function TestShiftLayer:testALightThatChangesWithShiftIsDeliveredOnce()
  layer.deliver({ makeLight(101, 6) })
  shift.setShifted(true)
  lu.assertEquals(layer.deliver({ makeLight(101, 9), makeLight(1, 4), makeLight(3, 7) }), { "3:7", "1:9", "2:0" })
  shift.setShifted(false)
  lu.assertEquals(layer.deliver({}), { "1:4", "2:0" })
end

-- a flashing light adds to the static one before it, and both come back
function TestShiftLayer:testAFlashingLightComesBackWithItsStaticOne()
  layer.deliver({ makeLight(1, 5), makeLight(1, 6, flashing) })
  shift.setShifted(true)
  layer.deliver({})
  shift.setShifted(false)
  lu.assertEquals(layer.deliver({}), { "1:5", "1:6:" .. flashing, "2:0" })
  -- any other light replaces them
  layer.deliver({ makeLight(1, 7, pulsing) })
  shift.setShifted(true)
  layer.deliver({})
  shift.setShifted(false)
  lu.assertEquals(layer.deliver({}), { "1:7:" .. pulsing, "2:0" })
end

function TestShiftLayer:testResetForgetsTheLightsAndWhatIsHeld()
  layer.deliver({ makeLight(1, 5) })
  layer.translate(1, 127)
  layer.reset()
  shift.setShifted(true)
  lu.assertEquals(layer.translate(1, 0), 101)
  layer.deliver({})
  shift.setShifted(false)
  lu.assertEquals(layer.deliver({}), { "1:0", "2:0" })
end
