return function(tbl, path)
  local current = tbl
  for token in string.gmatch(path, "([^%.]+)") do
    if current[token] then
      current = current[token]
    else
      return nil       -- This means the token/path doesn't exist in the table
    end
  end
  return current
end
