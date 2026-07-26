-- Labels for buttons whose values mean something other than On/Off. Keyed by
-- the device type (as mapped to a name in the remote map), then by the
-- parameter name, then by the value the host (Reason) reports.
--
-- A parameter listed here replaces the On/Off defaults entirely, so give it a
-- label for every value it can take.
return {
  subtractor = {
    ["Key Mode"] = { ["0"] = "Legato", ["1"] = "Retrig" },
  },
}
