local function byParam(groups)
  local rackUISettings = {}
  for rackUISetting, params in pairs(groups) do
    for _, param in ipairs(params) do
      rackUISettings[param] = rackUISetting
    end
  end
  return rackUISettings
end


return {
  algoritm = {
    ["Effect Select"] = byParam({
      -- REV
      [0] = {
        "Reverb Amount",
        "Reverb Damp",
        "Reverb Decay",
        "Reverb Early Reflections",
        "Reverb Size",
      },
      -- DLY
      [21] = {
        --[1] = {
        "Delay Amount",
        "Delay Feedback",
        "Delay Pan",
        "Delay PingPong",
        "Delay Sync",
        "Delay Synced Time",
        "Delay Time",
      },
      -- DIST
      [42] = {
        --[2] = {
        "Dist Amount",
        "Dist Drive",
        "Dist Tone",
        "Dist Type",
      },
      -- COMP
      [64] = {
        --[3] = {
        "Comp Attack",
        "Comp Ratio",
        "Comp Release",
        "Comp Threshold",
      },
      -- PHSR
      [85] = {
        --[4] = {
        "Mod Effect Amount",
        "Mod Effect Depth",
        "Mod Effect Feedback",
        "Mod Effect Rate",
        "Mod Effect Spread",
        "Mod Effect Type",
      },
      -- EQ
      [106] = {
        --[5] = {
        "EQ Freq",
        "EQ Gain",
        "EQ Hi Gain",
        "EQ Lo Gain",
        "EQ Q",
      },
      -- RESO
      [127] = {
        --[6] = {
        "Resonator Mix",
        "Resonator On",
        "Resonator Pitch",
        "Resonator Decay",
        "Resonator Select",
        "Resonator Width",
      },
    })
  }
}
