-- makes a light: the colour a control of the surface is to show, static
-- unless a behaviour (see colourBehaviour in config/constants.lua) is given.
-- The codec works its lights out for controls, which need not be where the
-- device has them (see shiftLayer.lua), and only turns them into MIDI on the
-- way to the surface.
return function(control, colour, behaviour)
  return { control = control, colour = colour, behaviour = behaviour }
end
