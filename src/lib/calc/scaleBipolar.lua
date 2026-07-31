return function(x, min, max)
  if x < 64 then
    return min + (x / 64) * -min
  else
    return ((x - 64) / 63) * max
  end
end
