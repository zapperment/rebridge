return function(tbl, func)
  local newTbl = {}
  for i, v in ipairs(tbl) do
    newTbl[i] = func(v)
  end
  return newTbl
end
