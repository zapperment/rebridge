-- Labels for buttons whose values mean something other than On/Off, matching
-- the labels printed on the device's own UI. Keyed by the device type (as
-- mapped to a name in the remote map), then by the parameter name, then by the
-- value the host (Reason) reports.
--
-- A parameter listed here replaces the On/Off defaults entirely, so give it a
-- label for every value it can take. A cycling parameter (see cycleParams)
-- that is not listed here shows its plain numerical value.

-- Osc1/Osc2 Wave (range 0-31, see "Reason Remote Support.pdf"): the first four
-- values are named waveforms, the rest count up from "5" to "32"
local function oscWaveLabels()
  local labels = {
    ["0"] = "Sawtooth",
    ["1"] = "Square",
    ["2"] = "Triangle",
    ["3"] = "Sine",
  }
  for value = 4, 31 do
    labels[tostring(value)] = tostring(value + 1)
  end
  return labels
end

return {
  subtractor = {
    ["Osc1 Wave"] = oscWaveLabels(),
    ["Osc2 Wave"] = oscWaveLabels(),
    ["Osc1 Phase Mode"] = { ["0"] = "X", ["1"] = "--", ["2"] = "O" },
    ["Osc2 Phase Mode"] = { ["0"] = "X", ["1"] = "--", ["2"] = "O" },
    ["Key Mode"] = { ["0"] = "Legato", ["1"] = "Retrig" },
    ["Filter Type"] = {
      ["0"] = "Notch",
      ["1"] = "HP 12",
      ["2"] = "BP 12",
      ["3"] = "LP 12",
      ["4"] = "LP 24",
    },
    ["LFO1 Wave"] = {
      ["0"] = "Triangle",
      ["1"] = "Inv. sawtooth",
      ["2"] = "Sawtooth",
      ["3"] = "Square",
      ["4"] = "Random",
      ["5"] = "Soft random",
    },
    ["LFO1 Dest"] = {
      ["0"] = "Osc 1,2",
      ["1"] = "Osc 2",
      ["2"] = "F.Freq",
      ["3"] = "FM",
      ["4"] = "Phase",
      ["5"] = "Mix",
    },
    ["LFO2 Dest"] = {
      ["0"] = "Osc 1,2",
      ["1"] = "Phase",
      ["2"] = "F.Freq 2",
      ["3"] = "Amp",
    },
    ["Mod Env Dest"] = {
      ["0"] = "Osc 1",
      ["1"] = "Osc 2",
      ["2"] = "Mix",
      ["3"] = "FM",
      ["4"] = "Phase",
      ["5"] = "Freq 2",
    },
    ["Ext Mod Select"] = { ["0"] = "A. Touch", ["1"] = "Expr", ["2"] = "Breath" }
  },
  algoritm = {
    ["Unison Count"] = { ["0"] = "2", ["64"] = "3", ["127"] = "4" },
    ["Dist Type"] = { ["0"] = "Dist", ["25"] = "Scream", ["51"] = "Tube", ["76"] = "Sine", ["102"] = "S/H", ["127"] = "Ring" },
    ["Mod Effect Type"] = { ["0"] = "Chorus", ["64"] = "Flanger", ["127"] = "Phaser" },
    ["Resonator Select"] = {},
    Mode1 = {
      ["0"] = "Off",
      ["32"] = "FM Operator",
      ["64"] = "Filter",
      ["96"] = "Shaper",
      ["127"] = "Osc & Noise",
    },
    Mode2 = {
      ["0"] = "Off",
      ["32"] = "FM Operator",
      ["64"] = "Filter",
      ["96"] = "Shaper",
      ["127"] = "Osc & Noise",
    },
    Mode3 = {
      ["0"] = "Off",
      ["32"] = "FM Operator",
      ["64"] = "Filter",
      ["96"] = "Shaper",
      ["127"] = "Osc & Noise",
    },
    Mode4 = {
      ["0"] = "Off",
      ["32"] = "FM Operator",
      ["64"] = "Filter",
      ["96"] = "Shaper",
      ["127"] = "Osc & Noise",
    },
    Mode5 = {
      ["0"] = "Off",
      ["32"] = "FM Operator",
      ["64"] = "Filter",
      ["96"] = "Shaper",
      ["127"] = "Osc & Noise",
    },
    Mode6 = {
      ["0"] = "Off",
      ["32"] = "FM Operator",
      ["64"] = "Filter",
      ["96"] = "Shaper",
      ["127"] = "Osc & Noise",
    },
    Mode7 = {
      ["0"] = "Off",
      ["32"] = "FM Operator",
      ["64"] = "Filter",
      ["96"] = "Shaper",
      ["127"] = "Osc & Noise",
    },
    Mode8 = {
      ["0"] = "Off",
      ["32"] = "FM Operator",
      ["64"] = "Filter",
      ["96"] = "Shaper",
      ["127"] = "Osc & Noise",
    },
    Mode9 = {
      ["0"] = "Off",
      ["32"] = "FM Operator",
      ["64"] = "Filter",
      ["96"] = "Shaper",
      ["127"] = "Osc & Noise",
    },
  }
}
