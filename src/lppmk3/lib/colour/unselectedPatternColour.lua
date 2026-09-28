local colours = require "src.lppmk3.lib.colour.config"
local patternColours = require "src.lppmk3.config.patternColours"

-- the colour the pad of a pattern value is shown in while the value is not
-- selected: off for a value left in the default colour, otherwise the dim
-- variant of the colour the user assigned to it
return function(colour)
  if colour == patternColours[1] then
    return colours.off
  end
  for _, variants in pairs(colours) do
    if type(variants) == "table" then
      for _, variant in pairs(variants) do
        if variant == colour then
          return variants.dim
        end
      end
    end
  end
  return colours.off
end
