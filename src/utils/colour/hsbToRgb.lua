return function(h, s, b)
  local c = b * s
  local x = c * (1 - math.abs((h / 60) % 2 - 1))
  local m = b - c

  local r1, g1, b1
  if h < 60 then
    r1, g1, b1 = c, x, 0
  elseif h < 120 then
    r1, g1, b1 = x, c, 0
  elseif h < 180 then
    r1, g1, b1 = 0, c, x
  elseif h < 240 then
    r1, g1, b1 = 0, x, c
  elseif h < 300 then
    r1, g1, b1 = x, 0, c
  else
    r1, g1, b1 = c, 0, x
  end

  return
      math.floor((r1 + m) * 255 + 0.5),
      math.floor((g1 + m) * 255 + 0.5),
      math.floor((b1 + m) * 255 + 0.5)
end
