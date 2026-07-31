return function(x, min, max)
  return min + (x / 127) * (max - min)
end
