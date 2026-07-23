local colours = require("src.config.colours")
local getColourForValue = require("src.utils.colour.getColourForValue");

return function(name, value)
  return getColourForValue(colours[name], value)
end
