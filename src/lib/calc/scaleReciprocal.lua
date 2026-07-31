return function(x)
  if x >= 126 then
    return math.huge
  end
  return 126 / (126 - x)
end
