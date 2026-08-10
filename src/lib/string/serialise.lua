local function serialise(o)
  if type(o) == "string" then
    return string.format("%q", o)
  elseif type(o) == "table" then
    local tokens = {}
    for k, v in pairs(o) do
      table.insert(tokens, "[" .. serialise(k) .. "]=" .. serialise(v))
    end
    return "{" .. table.concat(tokens, ",") .. "}"
  else
    -- For other data types (e.g. number or boolean), simply convert to string
    return tostring(o)
  end
end

return serialise
