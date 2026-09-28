local patternColours = require "src.lppmk3.config.patternColours"

-- the colour that follows the given one in the cycle of pattern colours,
-- wrapping around at the end; a colour that is not in the cycle starts it over
return function(colour)
  for index, patternColour in ipairs(patternColours) do
    if patternColour == colour then
      return patternColours[index % #patternColours + 1]
    end
  end
  return patternColours[1]
end
