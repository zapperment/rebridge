local test = require "test.lib._"
local lu = test.luaUnit
local colours = require "src.lpcommon.lib.colour.config"
local ledColour = require "src.lpm.lib.midi.ledColour"

-- The LEDs of the Launchpad Mini are red, green or both, which gives
-- amber, so each colour of the codec's palette becomes the nearest of the
-- three, as bright as the palette entry is.
TestLedColourLPM = {}

-- the brightness of the red and of the green element
local function led(colour)
  return { ledColour(colour) }
end

function TestLedColourLPM:testOffIsDark()
  lu.assertEquals(led(colours.off), { 0, 0 })
end

function TestLedColourLPM:testWhiteIsAmber()
  lu.assertEquals(led(colours.white.dim), { 1, 1 })
  lu.assertEquals(led(colours.white.neutral), { 2, 2 })
  lu.assertEquals(led(colours.white.bright), { 3, 3 })
end

function TestLedColourLPM:testAColourIsAsBrightAsItsPaletteEntry()
  lu.assertEquals(led(colours.red.dim), { 1, 0 })
  lu.assertEquals(led(colours.red.neutral), { 2, 0 })
  lu.assertEquals(led(colours.red.vibrant), { 3, 0 })
  lu.assertEquals(led(colours.red.pastel), { 3, 0 })
  lu.assertEquals(led(colours.green.dim), { 0, 1 })
  lu.assertEquals(led(colours.green.vibrant), { 0, 3 })
end

function TestLedColourLPM:testEveryColourIsTheNearestOfRedAmberAndGreen()
  local red, amber, green = { 3, 0 }, { 3, 3 }, { 0, 3 }
  local expected = {
    red = red, purple = red, fuchsia = red, pink = red,
    orange = amber, yellow = amber,
    lime = green, green = green, turquoise = green, cyan = green,
    lightBlue = green, blue = green, darkBlue = green,
  }
  local count = 0
  for name, colour in pairs(colours) do
    if name ~= "off" and name ~= "white" then
      lu.assertEquals(led(colour.vibrant), expected[name], name)
      count = count + 1
    end
  end
  lu.assertEquals(count, 13)
end

-- the functions are red for stop, yellow for mute and blue for solo, and
-- stay apart
function TestLedColourLPM:testTheFunctionColoursDiffer()
  lu.assertNotEquals(led(colours.red.vibrant), led(colours.yellow.vibrant))
  lu.assertNotEquals(led(colours.red.vibrant), led(colours.blue.vibrant))
  lu.assertNotEquals(led(colours.yellow.vibrant), led(colours.blue.vibrant))
end

-- a dim light and a vibrant one never look the same, whatever the colour
function TestLedColourLPM:testDimAndVibrantDiffer()
  for name, colour in pairs(colours) do
    if name ~= "off" and name ~= "white" then
      lu.assertNotEquals(led(colour.dim), led(colour.vibrant), name)
      lu.assertNotEquals(led(colour.dim), { 0, 0 }, name)
    end
  end
end

-- the palette has entries the codec does not use
function TestLedColourLPM:testAnyOtherEntryIsLit()
  for colour = 1, 127 do
    local red, green = ledColour(colour)
    lu.assertTrue(red + green > 0, colour)
    lu.assertTrue(red <= 3 and green <= 3, colour)
  end
end
