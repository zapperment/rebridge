-- whether a control is one of the pads of the 8x8 grid, which are numbered 11
-- at the bottom left to 88 at the top right; every other number is a button's
return function(control)
  local column = control % 10
  return control >= 11 and control <= 88 and column >= 1 and column <= 8
end
