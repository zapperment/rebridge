-- How a selecting device's selection shows on the surface: the label of each
-- option, shown on its selection button and on the overlay display when it is
-- selected, the label shown there when no option is selected, and the colour of
-- the selection buttons. Keyed by the device type (as mapped to a name in the
-- remote map).
--
-- A selecting device that is not listed here still works: its options are
-- labelled by their numbers, and its selection buttons keep their default
-- colours (see config/items).

-- the labels of a player's patterns, "Pattern 1" … "Pattern 8"
local function patterns()
  local labels = {}
  for pattern = 1, 8 do
    table.insert(labels, "Pattern " .. pattern)
  end
  return labels
end

return {
  bassline = {
    options = patterns(),
    none = "No pattern",
    colour = "green",
  },
}
