local colours = require("src.lib.colour.config").colours
local getColourForValue = require("src.lib.colour.getColourForValue");

return function(name, value)
  return getColourForValue(colours[name], value)
end
