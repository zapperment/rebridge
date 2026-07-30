-- Parameters that cycle through their values when the button they are mapped
-- to is pressed, mirroring the momentary buttons on the device's own UI (e.g.
-- SubTractor's Phase Mode button steps through the three phase modes). Keyed
-- by device type, then by parameter name; the value is the number of values
-- the parameter can take, from the tables in "Reason Remote Support.pdf"
-- (number of values = max + 1).
--
-- Two-value parameters do not belong here: they stay ordinary toggles.
return {
  subtractor = {
    ["Osc1 Phase Mode"] = 3,
    ["Osc2 Phase Mode"] = 3,
    ["Filter Type"] = 5,
    ["LFO1 Wave"] = 6,
    ["LFO1 Dest"] = 6,
    ["LFO2 Dest"] = 4,
    ["Mod Env Dest"] = 6,
    ["Ext Mod Select"] = 3,
  },
  algoritm = {
    ["Mode1"] = 5,
    ["Mode2"] = 5,
    ["Mode3"] = 5,
    ["Mode4"] = 5,
    ["Mode5"] = 5,
    ["Mode6"] = 5,
    ["Mode7"] = 5,
    ["Mode8"] = 5,
    ["Mode9"] = 5,
  }
}
