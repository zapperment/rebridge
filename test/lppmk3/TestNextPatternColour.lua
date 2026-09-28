local test = require "test.lib._"
local lu = test.luaUnit
local colours = require "src.lppmk3.lib.colour.config"
local nextPatternColour = require "src.lppmk3.lib.colour.nextPatternColour"

TestNextPatternColour = {}

function TestNextPatternColour:testCyclesThroughAllColoursAndBackToWhite()
  local expected = {
    colours.red.vibrant,
    colours.orange.vibrant,
    colours.yellow.vibrant,
    colours.lime.vibrant,
    colours.green.vibrant,
    colours.turquoise.vibrant,
    colours.cyan.vibrant,
    colours.lightBlue.vibrant,
    colours.blue.vibrant,
    colours.darkBlue.vibrant,
    colours.purple.vibrant,
    colours.fuchsia.vibrant,
    colours.pink.vibrant,
    colours.white.bright,
  }
  local colour = colours.white.bright
  for _, expectedColour in ipairs(expected) do
    colour = nextPatternColour(colour)
    lu.assertEquals(colour, expectedColour)
  end
end

function TestNextPatternColour:testStartsOverWithColourNotInCycle()
  lu.assertEquals(nextPatternColour(colours.red.pastel), colours.white.bright)
  lu.assertEquals(nextPatternColour(nil), colours.white.bright)
end
