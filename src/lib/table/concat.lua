return function(a, b)
  local result = {}
  for _, v in ipairs(a) do table.insert(result, v) end
  for _, v in ipairs(b) do table.insert(result, v) end
  return result
end
