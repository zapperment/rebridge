local colours = require "src.lppmk3.lib.colour.config"

-- The buttons of the switch meter, the second row from the bottom, from left
-- to right: the controller of each and the colour it is lit in
return {
  { controller = 101, colour = colours.green },
  { controller = 102, colour = colours.green },
  { controller = 103, colour = colours.green },
  { controller = 104, colour = colours.green },
  { controller = 105, colour = colours.green },
  { controller = 106, colour = colours.yellow },
  { controller = 107, colour = colours.yellow },
  { controller = 108, colour = colours.red },
}
