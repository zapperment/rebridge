local midi = require "src.lppmk3.lib.midi._"
local col = require "src.lppmk3.lib.colour._"
local spike = require "src.lppmk3.spike.state"

local topLeftPad = 81

-- the colours of Launchnik in its order; white has no vibrant palette entry
local palette = {
  { dim = col.config.white.dim, vibrant = col.config.white.bright },
  col.config.red, col.config.orange, col.config.yellow, col.config.lime,
  col.config.green, col.config.turquoise, col.config.cyan,
  col.config.lightBlue, col.config.blue, col.config.darkBlue,
  col.config.purple, col.config.fuchsia, col.config.pink,
}

-- the light is a frame of Launchnik's film strip: 0 is unlit, then dim and
-- vibrant for each colour
local function paletteEntry(light)
  if light == 0 then
    return col.config.off
  end
  local colour = palette[math.floor((light - 1) / 2) + 1]
  return light % 2 == 1 and colour.dim or colour.vibrant
end

-- THROWAWAY: shows the light of the Launchnik Spike device on the top left pad
return function()
  if not spike.lightChanged then
    return {}
  end
  spike.lightChanged = false
  return { midi.makeColourEvent(topLeftPad, paletteEntry(spike.light)) }
end
