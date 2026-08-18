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
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Pan 2"] = {
      dependsOn = "Mode2",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Pan 3"] = {
      dependsOn = "Mode3",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Pan 4"] = {
      dependsOn = "Mode4",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Pan 5"] = {
      dependsOn = "Mode5",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Pan 6"] = {
      dependsOn = "Mode6",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Pan 7"] = {
      dependsOn = "Mode7",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Pan 8"] = {
      dependsOn = "Mode8",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
    },
    ["Pan 9"] = {
      dependsOn = "Mode9",
      colours = { ["0"] = "black", ["32"] = "blue", ["64"] = "orange", ["96"] = "white", ["127"] = "red" }
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
      useOtherParamWhenValue = 127
    },
    ["Delay Synced Time"] = {
      dependsOn = "Delay Sync",
      useOtherParamWhenValue = 0
    },
  },
}
