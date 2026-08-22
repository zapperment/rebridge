-- GENERATED FILE, DO NOT EDIT
--
-- Written by scripts/extractCombinatorLabels.js, which reads the labels out of
-- Combinator patch files; run `yarn extract:combi` to bring it up to date.
--
-- The labels a Combinator patch writes on its front panel, keyed by the name
-- Reason reports for the patch and then by the remote parameter the label
-- belongs to. Reason reports nothing but "Rotary 1" ... "Button 16" for a
-- Combinator, so this is the only way the labels can reach the control surface
-- (see src/lib/display/getDisplayName.lua). Slots the patch left at their
-- default are left out, as those already show the right thing.
local labels = {}

labels["combi-patch-example"] = {
  ["Rotary 1"] = "Ch. 1 Vol.",
  ["Rotary 2"] = "Ch. 2 Vol.",
  ["Rotary 3"] = "Ch. 3 Vol.",
  ["Rotary 4"] = "Ch. 4 Vol.",
  ["Rotary 5"] = "Ch. 5 Vol.",
  ["Rotary 6"] = "Ch. 6 Vol.",
  ["Rotary 7"] = "Ch. 7 Vol.",
  ["Rotary 8"] = "Ch. 8 Vol.",
  ["Rotary 9"] = "Pattern",
  ["Rotary 10"] = "Chop",
  ["Rotary 11"] = "Delay",
  ["Rotary 12"] = "Reverb",
  ["Rotary 13"] = "Compressor",
  ["Rotary 14"] = "Clean",
  ["Rotary 15"] = "DUMMY 13",
  ["Button 1"] = "Ch. 1 On",
  ["Button 2"] = "Ch. 2 On",
  ["Button 3"] = "Ch. 3 On",
  ["Button 4"] = "Ch. 4 On",
  ["Button 5"] = "Ch. 5 On",
  ["Button 6"] = "Ch. 6 On",
  ["Button 7"] = "Ch. 7 On",
  ["Button 8"] = "Ch. 8 On",
  ["Button 9"] = "Rev. to Comp.",
}

-- the names these patches give the Combinator in the rack, to fall back on
-- when Reason reports no patch name for it
labels["Bent Beat [UCLUB]"] = labels["combi-patch-example"]

return labels
