return function(hex)
  local num = tonumber(hex, 16)
  local r = math.floor(num / 65536) % 256
  local g = math.floor(num / 256) % 256
  local b = num % 256
  return r, g, b
end
