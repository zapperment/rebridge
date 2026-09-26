-- Shortenings of parameter names for the displays of the surface, which cut
-- off names that are too long for them. Keyed by the device type, listing Lua
-- patterns and what to replace them with; every pattern of a device is applied
-- to every parameter name shown for it, in the order listed.
--
-- The Bassline Generator names each parameter after its pattern ("Pattern 3
-- OnBeat Source"), which the selection buttons already show, so the prefix goes.
return {
  bassline = {
    { find = "^Pattern %d+ ", replace = "" },
  },
  polystep = {
    { find = "^P%d+ ", replace = "" },
  },
}
