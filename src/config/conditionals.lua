-- Labels for parameters whose display depends on the setting of another,
-- two-valued parameter of the same device: while the parameter named by
-- dependsOn is on, the 0-127 value range is divided into as many equal buckets
-- as there are labels, and the matching label is shown instead of the value.
-- Keyed by the device type, then by the parameter name.
--
-- SubTractor's LFO1 Rate turns into a note-length division while LFO1 sync is
-- enabled, from 16/4 at the bottom of the range to 1/32 at the top.
--
-- A parameter can depend on more than one other parameter: next to the one
-- named by dependsOn, it can list overrides, each naming a further parameter
-- with colours of its own. The first override that has a colour for the current
-- value of its parameter wins over the colour dependsOn would give. The
-- Algorithm's Pan parameters work that way: their LED takes the colour of the
-- module's Mode, but stays unlit while the module's Out is off, because there is
-- no panning to be done then.
--
-- Instead of a single conditional, a parameter can also be given a list of them,
-- which is how a parameter that is replaced by different parameters depending on
-- several switches is described. The parameter then only displays while every
-- conditional in the list is happy with the current value of the parameter it
-- depends on (see lib/display/shouldDisplay), and the first conditional that has
-- a label or a colour to give is the one that gives it. Ripley's Delay Time is
-- such a parameter: Delay Tempo Sync turns it into Synced Time, and Dual Delay
-- splits it into Delay Time L and Delay Time R.
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
    ["Freq 1"] = {
      dependsOn = "Mode1",
      variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc" },
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Freq 2"] = {
      dependsOn = "Mode2",
      variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", },
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Freq 3"] = {
      dependsOn = "Mode3",
      variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", },
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Freq 4"] = {
      dependsOn = "Mode4",
      variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", },
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Freq 5"] = {
      dependsOn = "Mode5",
      variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", },
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Freq 6"] = {
      dependsOn = "Mode6",
      variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", },
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Freq 7"] = {
      dependsOn = "Mode7",
      variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", },
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Freq 8"] = {
      dependsOn = "Mode8",
      variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", },
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Freq 9"] = {
      dependsOn = "Mode9",
      variations = { ["32"] = "Freq 1 Op/Osc", ["127"] = "Freq 1 Op/Osc", },
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Reso 1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Reso 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Reso 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Reso 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Reso 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Reso 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Reso 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Reso 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Reso 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["ShaperMix 1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["ShaperMix 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["ShaperMix 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["ShaperMix 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["ShaperMix 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["ShaperMix 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["ShaperMix 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["ShaperMix 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["ShaperMix 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Wave Mod 1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Wave Mod 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Wave Mod 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Wave Mod 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Wave Mod 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Wave Mod 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Wave Mod 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Wave Mod 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Wave Mod 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Symmetry 1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Symmetry 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Symmetry 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Symmetry 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Symmetry 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Symmetry 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Symmetry 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Symmetry 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Symmetry 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Drive 1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Drive 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Drive 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Drive 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Drive 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Drive 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Drive 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Drive 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Drive 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "black", ["96"] = "white", ["127"] = "black" }
    },
    ["Filter Env 1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Filter Env 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Filter Env 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Filter Env 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Filter Env 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Filter Env 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Filter Env 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Filter Env 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Filter Env 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "black", ["64"] = "orange", ["96"] = "black", ["127"] = "black" }
    },
    ["Vel 1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Vel 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Vel 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Vel 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Vel 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Vel 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Vel 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Vel 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Vel 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "black", ["127"] = "red" }
    },
    ["Level 1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Level 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Level 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Level 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Level 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Level 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Level 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Level 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Level 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Tune 1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Tune 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Tune 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Tune 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Tune 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Tune 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Tune 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Tune 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Tune 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "black", ["96"] = "black", ["127"] = "red" }
    },
    ["Pan 1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" },
      overrides = {
        { dependsOn = "Out 1", colours = { ["0"] = "black" } },
      }
    },
    ["Pan 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" },
      overrides = {
        { dependsOn = "Out 2", colours = { ["0"] = "black" } },
      }
    },
    ["Pan 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" },
      overrides = {
        { dependsOn = "Out 3", colours = { ["0"] = "black" } },
      }
    },
    ["Pan 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" },
      overrides = {
        { dependsOn = "Out 4", colours = { ["0"] = "black" } },
      }
    },
    ["Pan 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" },
      overrides = {
        { dependsOn = "Out 5", colours = { ["0"] = "black" } },
      }
    },
    ["Pan 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" },
      overrides = {
        { dependsOn = "Out 6", colours = { ["0"] = "black" } },
      }
    },
    ["Pan 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" },
      overrides = {
        { dependsOn = "Out 7", colours = { ["0"] = "black" } },
      }
    },
    ["Pan 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" },
      overrides = {
        { dependsOn = "Out 8", colours = { ["0"] = "black" } },
      }
    },
    ["Pan 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" },
      overrides = {
        { dependsOn = "Out 9", colours = { ["0"] = "black" } },
      }
    },
    ["Mode1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "white", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Mode2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "white", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Mode3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "white", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Mode4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "white", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Mode5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "white", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Mode6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "white", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Mode7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "white", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Mode8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "white", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Mode9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "white", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Out 1"] = {
      dependsOn = "Mode1",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Out 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Out 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Out 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Out 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Out 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Out 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Out 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Out 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Delay Time"] = {
      dependsOn = "Delay Sync",
      useOtherParamWhenValue = true
    },
    ["Delay Synced Time"] = {
      dependsOn = "Delay Sync",
      useOtherParamWhenValue = false
    },
    ["LFO 1 Rate"] = {
      dependsOn = "LFO 1 Tempo Sync",
      useOtherParamWhenValue = true
    },
    ["LFO 1 Sync Rate"] = {
      dependsOn = "LFO 1 Tempo Sync",
      useOtherParamWhenValue = false
    },
    ["LFO 2 Rate"] = {
      dependsOn = "LFO 2 Tempo Sync",
      useOtherParamWhenValue = true
    },
    ["LFO 2 Sync Rate"] = {
      dependsOn = "LFO 2 Tempo Sync",
      useOtherParamWhenValue = false
    },
    ["LFO 3 Rate"] = {
      dependsOn = "LFO 3 Tempo Sync",
      useOtherParamWhenValue = true
    },
    ["LFO 3 Sync Rate"] = {
      dependsOn = "LFO 3 Tempo Sync",
      useOtherParamWhenValue = false
    },
    ["Curve 1 Rate"] = {
      dependsOn = "Curve 1 Tempo Sync",
      useOtherParamWhenValue = true
    },
    ["Curve 1 Sync Rate"] = {
      dependsOn = "Curve 1 Tempo Sync",
      useOtherParamWhenValue = false
    },
    ["Curve 2 Rate"] = {
      dependsOn = "Curve 2 Tempo Sync",
      useOtherParamWhenValue = true
    },
    ["Curve 2 Sync Rate"] = {
      dependsOn = "Curve 2 Tempo Sync",
      useOtherParamWhenValue = false
    },
  },
  ripley = {
    ["Delay Time"] = {
      {
        dependsOn = "Delay Tempo Sync",
        useOtherParamWhenValue = true
      },
      {
        dependsOn = "Dual Delay",
        useOtherParamWhenValue = true
      },
    },
    ["Synced Time"] = {
      {
        dependsOn = "Delay Tempo Sync",
        useOtherParamWhenValue = false
      },
      {
        dependsOn = "Dual Delay",
        useOtherParamWhenValue = true
      }
    },
    ["Delay Time L"] = {
      {
        dependsOn = "Delay Tempo Sync",
        useOtherParamWhenValue = true
      },
      {
        dependsOn = "Dual Delay",
        useOtherParamWhenValue = false
      }
    },
    ["Synced Time L"] = {
      {
        dependsOn = "Delay Tempo Sync",
        useOtherParamWhenValue = false
      },
      {
        dependsOn = "Dual Delay",
        useOtherParamWhenValue = false
      },
    },
    ["Delay Time R"] = {
      {
        dependsOn = "Delay Tempo Sync",
        useOtherParamWhenValue = true
      },
      {
        dependsOn = "Dual Delay",
        useOtherParamWhenValue = false
      },
    },
    ["Synced Time R"] = {
      {
        dependsOn = "Delay Tempo Sync",
        useOtherParamWhenValue = false
      },
      {
        dependsOn = "Dual Delay",
        useOtherParamWhenValue = false
      }
    },
    ["Hi Cut Freq"] = {
      dependsOn = "Filter Type",
      colours = { ["127"] = "black", ["0"] = "pink" },
    },
    ["Lo Cut Freq"] = {
      dependsOn = "Filter Type",
      colours = { ["127"] = "black", ["0"] = "pink" },
    },
    ["Band Freq Shift"] = {
      dependsOn = "Filter Type",
      colours = { ["0"] = "black", ["127"] = "pink" },
    },
    ["Band Offset L-R"] = {
      dependsOn = "Filter Type",
      colours = { ["0"] = "black", ["127"] = "pink" },
    },
    ["LFO1 Rate"] = {
      dependsOn = "LFO1 Sync",
      useOtherParamWhenValue = true
    },
    ["LFO1 Synced Rate"] = {
      dependsOn = "LFO1 Sync",
      useOtherParamWhenValue = false
    },
    ["LFO2 Rate"] = {
      dependsOn = "LFO2 Sync",
      useOtherParamWhenValue = true
    },
    ["LFO2 Synced Rate"] = {
      dependsOn = "LFO2 Sync",
      useOtherParamWhenValue = false
    },
  },
  legendhz = {
    ["MSEG 1 Rate"] = {
      dependsOn = "MSEG 1 Sync",
      useOtherParamWhenValue = true,
    },
    ["MSEG 1 Rate Sync"] = {
      dependsOn = "MSEG 1 Sync",
      useOtherParamWhenValue = false,
    },
    ["MSEG 2 Rate"] = {
      dependsOn = "MSEG 2 Sync",
      useOtherParamWhenValue = true,
    },
    ["MSEG 2 Rate Sync"] = {
      dependsOn = "MSEG 2 Sync",
      useOtherParamWhenValue = false,
    },
    ["MSEG 3 Rate"] = {
      dependsOn = "MSEG 3 Sync",
      useOtherParamWhenValue = true,
    },
    ["MSEG 3 Rate Sync"] = {
      dependsOn = "MSEG 3 Sync",
      useOtherParamWhenValue = false,
    },
    ["MSEG 4 Rate"] = {
      dependsOn = "MSEG 4 Sync",
      useOtherParamWhenValue = true,
    },
    ["MSEG 4 Rate Sync"] = {
      dependsOn = "MSEG 4 Sync",
      useOtherParamWhenValue = false,
    },
  },
  polytone = {
    ["Global LFO Rate"] = {
      dependsOn = "Global LFO Sync",
      useOtherParamWhenValue = true,
    },
    ["Global LFO Sync Rate"] = {
      dependsOn = "Global LFO Sync",
      useOtherParamWhenValue = false,
    },
  }
}
