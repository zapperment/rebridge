local function serialise(o)
  if type(o) == "number" then
    return tostring(o)
  elseif type(o) == "string" then
    return string.format("%q", o)
  elseif type(o) == "table" then
    local tokens = {}
    for k, v in pairs(o) do
      table.insert(tokens, "[" .. serialise(k) .. "]=" .. serialise(v))
    end
    return "{" .. table.concat(tokens, ",") .. "}"
  else
    -- For unsupported data types, simply convert to string (this might not be unique across different types!)
    return tostring(o)
  end
end

return serialise
