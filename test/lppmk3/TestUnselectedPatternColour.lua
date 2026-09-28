local test = require "test.lib._"
local lu = test.luaUnit
local colours = require "src.lppmk3.lib.colour.config"
local patternColours = require "src.lppmk3.config.patternColours"
local unselectedPatternColour = require "src.lppmk3.lib.colour.unselectedPatternColour"

TestUnselectedPatternColour = {}

function TestUnselectedPatternColour:testWhiteIsOff()
  lu.assertEquals(unselectedPatternColour(colours.white.dim), colours.off)
end

function TestUnselectedPatternColour:testOtherColoursAreDim()
  lu.assertEquals(unselectedPatternColour(colours.red.vibrant), colours.red.dim)
  lu.assertEquals(unselectedPatternColour(colours.lightBlue.vibrant), colours.lightBlue.dim)
  lu.assertEquals(unselectedPatternColour(colours.pink.vibrant), colours.pink.dim)
end

function TestUnselectedPatternColour:testEveryPatternColourOtherThanWhiteHasDimVariant()
  for index = 2, #patternColours do
    local dim = unselectedPatternColour(patternColours[index])
    lu.assertNotEquals(dim, colours.off)
    lu.assertEquals(dim, patternColours[index] + 2)
  end
end

function TestUnselectedPatternColour:testUnknownColourIsOff()
  lu.assertEquals(unselectedPatternColour(nil), colours.off)
end
