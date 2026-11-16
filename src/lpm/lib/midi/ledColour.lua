-- The surface's LEDs have a red and a green element, each off or at one of
-- three brightnesses, which mix to amber. The codec's colours are entries of
-- the palette of the later Launchpads (see src/lpcommon/lib/colour/config.lua),
-- so each becomes the nearest of red, amber and green: how bright an entry is
-- says more about a button than its hue, and three hues leave dim and bright
-- easy to tell apart.

local red = { red = 1, green = 0 }
local amber = { red = 1, green = 1 }
local green = { red = 0, green = 1 }

-- from entry 4 on, the palette has four entries for each colour
local hues = {
  red,   -- red
  amber, -- orange
  amber, -- yellow
  green, -- lime
  green, -- between lime and green
  green, -- green
  green, -- turquoise
  green, -- cyan
  green, -- light blue
  green, -- blue
  green, -- dark blue
  red,   -- purple
  red,   -- fuchsia
  red,   -- pink
}

-- the brightness of the four entries of a colour: pastel, vibrant, neutral
-- and dim
local brightnesses = { 3, 3, 2, 1 }

-- the brightness, 0 to 3, of the red and of the green element that stand for
-- the palette entry given
return function(colour)
  if colour == 0 then
    return 0, 0
  end
  -- entries 1 to 3 are white: dim, neutral and bright
  if colour <= 3 then
    return colour, colour
  end
  local hue = hues[math.floor((colour - 4) / 4) + 1] or amber
  local brightness = brightnesses[(colour - 4) % 4 + 1]
  return hue.red * brightness, hue.green * brightness
end
