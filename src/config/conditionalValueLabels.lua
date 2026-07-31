-- Labels for parameters whose display depends on the setting of another,
-- two-valued parameter of the same device: while the parameter named by
-- dependsOn is on, the 0-127 value range is divided into as many equal buckets
-- as there are labels, and the matching label is shown instead of the value.
-- Keyed by the device type, then by the parameter name.
--
-- SubTractor's LFO1 Rate turns into a note-length division while LFO1 sync is
-- enabled, from 16/4 at the bottom of the range to 1/32 at the top.
return {
  subtractor = {
    ["LFO1 Rate"] = {
      dependsOn = "LFO Sync Enable",
      labels = {
        "16/4", "12/4", "8/4", "7/4", "6/4", "5/4", "4/4", "3/4",
        "2/4", "3/8", "1/4", "3/16", "1/8", "1/8T", "1/16", "1/32",
      },
    },
  },
  algoritm = {
    ["Freq 1"] = { dependsOn = "Mode1", variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", } },
    ["Freq 2"] = { dependsOn = "Mode1", variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", } },
    ["Freq 3"] = { dependsOn = "Mode1", variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", } },
    ["Freq 4"] = { dependsOn = "Mode1", variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", } },
    ["Freq 5"] = { dependsOn = "Mode1", variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", } },
    ["Freq 6"] = { dependsOn = "Mode1", variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", } },
    ["Freq 7"] = { dependsOn = "Mode1", variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", } },
    ["Freq 8"] = { dependsOn = "Mode1", variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", } },
    ["Freq 9"] = { dependsOn = "Mode1", variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", } },
  }
}
