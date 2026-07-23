return function(r, g, b)
  r = r / 255
  g = g / 255
  b = b / 255
  local max = math.max(r, g, b)
  local min = math.min(r, g, b)
  local delta = max - min

  local h = 0
  if delta ~= 0 then
    if max == r then
      h = 60 * (((g - b) / delta) % 6)
    elseif max == g then
      h = 60 * ((b - r) / delta + 2)
    else
      h = 60 * ((r - g) / delta + 4)
    end
  end
  if h < 0 then h = h + 360 end

  local s = 0
  if max ~= 0 then s = delta / max end

  return h, s, max
end
