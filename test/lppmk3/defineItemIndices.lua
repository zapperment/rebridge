local items = require "src.lppmk3.config.items"

-- gives the items the indices remote_init would give them, without loading
-- the codec, which would replace the Launch Control XL3's globals
return function()
  local names = {}
  for name in pairs(items) do
    table.insert(names, name)
  end
  table.sort(names)
  for index, name in ipairs(names) do
    items[name].index = index
  end
end
