return function(value, decimals)
  local mult = 10 ^ (decimals or 0)
  local v = value * mult
  if v >= 0 then
    return math.floor(v + 0.5) / mult
  else
    return math.ceil(v - 0.5) / mult
  end
end
