-- Resolves a dot separated path in a table and returns the value stored there
-- along with the table that directly contains it.
--
-- The parent is only reported for nested paths, so that the table passed in is
-- never returned as a parent of itself. A missing value in an existing parent
-- still reports that parent, a missing intermediate reports neither.
return function(tbl, path)
  local tokens = {}
  for token in string.gmatch(path, "([^%.]+)") do
    tokens[#tokens + 1] = token
  end
  local current = tbl
  for i = 1, #tokens do
    if type(current) ~= "table" then
      return nil, nil -- an intermediate token doesn't exist in the table
    end
    if i == #tokens then
      return current[tokens[i]], i > 1 and current or nil
    end
    current = current[tokens[i]]
  end
  return current, nil -- empty path
end
