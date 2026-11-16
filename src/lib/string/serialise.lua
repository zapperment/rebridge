local serialise

-- whether the key a goes before the key b: numbers first, in their order,
-- then everything else in the order of what it is serialised to
local function goesBefore(a, b)
  local aIsNumber = type(a.key) == "number"
  local bIsNumber = type(b.key) == "number"
  if aIsNumber and bIsNumber then
    return a.key < b.key
  end
  if aIsNumber ~= bIsNumber then
    return aIsNumber
  end
  return a.text < b.text
end

-- The entries of a table are in the order of their keys, so that the same
-- table always gives the same text: pairs() goes through them in an order
-- that differs from run to run.
serialise = function(o)
  if type(o) == "string" then
    return string.format("%q", o)
  elseif type(o) == "table" then
    local keys = {}
    for k in pairs(o) do
      table.insert(keys, { key = k, text = serialise(k) })
    end
    table.sort(keys, goesBefore)
    local tokens = {}
    for _, entry in ipairs(keys) do
      table.insert(tokens, "[" .. entry.text .. "]=" .. serialise(o[entry.key]))
    end
    return "{" .. table.concat(tokens, ",") .. "}"
  else
    -- For other data types (e.g. number or boolean), simply convert to string
    return tostring(o)
  end
end

return serialise
