local function deepCopy(orig)
  local origType = type(orig)
  local copy

  if origType == 'table' then
    copy = {}
    for origKey, origValue in next, orig, nil do
      copy[deepCopy(origKey)] = deepCopy(origValue)
    end
    setmetatable(copy, deepCopy(getmetatable(orig)))
  else   -- number, string, boolean, etc.
    copy = orig
  end
  return copy
end

return deepCopy
