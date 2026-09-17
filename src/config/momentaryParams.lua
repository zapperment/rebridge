-- Parameters that behave like the pushbuttons on the device's own UI (e.g. the
-- Bassline Generator's Run button): the host flips the parameter whenever the
-- button goes down, and reports back whether the button is down, never whether
-- the parameter is on. The codec therefore sends the press and the release,
-- lights the button brightly only while it is held down, and shows no value for
-- it, as it has none to show.
--
-- Keyed by device type, listing the parameter names. Not to be confused with
-- the cycle parameters (see cycleParams), which the codec steps through itself.
local function byName(params)
  local names = {}
  for _, param in ipairs(params) do
    names[param] = true
  end
  return names
end

return {
  bassline = byName {
    "Run",
  },
  polystep = byName {
    "Run",
    "Variation 1 Trigger",
    "Variation 2 Trigger",
    "Variation 3 Trigger",
    "Variation 4 Trigger",
  },
}
