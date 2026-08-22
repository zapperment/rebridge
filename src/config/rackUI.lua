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
        "Reverb Amount", "Reverb Damp", "Reverb Decay",
        "Reverb Early Reflections", "Reverb Size",
      },
      -- DLY
      [21] = {
        --[1] = {
        "Delay Amount", "Delay Feedback", "Delay Pan", "Delay PingPong",
        "Delay Sync", "Delay Synced Time", "Delay Time",
      },
      -- DIST
      [42] = {
        --[2] = {
        "Dist Amount", "Dist Drive",
        "Dist Tone", "Dist Type",
      },
      -- COMP
      [64] = {
        --[3] = {
        "Comp Attack", "Comp Ratio",
        "Comp Release", "Comp Threshold",
      },
      -- PHSR
      [85] = {
        --[4] = {
        "Mod Effect Amount", "Mod Effect Depth", "Mod Effect Feedback",
        "Mod Effect Rate", "Mod Effect Spread", "Mod Effect Type",
      },
      -- EQ
      [106] = {
        --[5] = {
        "EQ Freq", "EQ Gain", "EQ Hi Gain",
        "EQ Lo Gain", "EQ Q",
      },
      -- RESO
      [127] = {
        --[6] = {
        "Resonator Mix", "Resonator On", "Resonator Pitch",
        "Resonator Decay", "Resonator Select", "Resonator Width",
      },
    }),
    ["LFO Select"] = byParam({
      -- LFO1
      [0] = {
        "LFO 1 Wave", "LFO 1 Rate", "LFO 1 Sync Rate", "LFO 1 Delay",
        "LFO 1 Tempo Sync", "LFO 1 Key Sync", "LFO 1 Global",
      },
      -- LFO2
      [32] = {
        "LFO 2 Wave", "LFO 2 Rate", "LFO 2 Sync Rate", "LFO 2 Delay",
        "LFO 2 Tempo Sync", "LFO 2 Key Sync", "LFO 2 Global",
      },
      -- LFO3
      [64] = {
        "LFO 3 Wave", "LFO 3 Rate", "LFO 3 Sync Rate", "LFO 3 Delay",
        "LFO 3 Tempo Sync", "LFO 3 Key Sync", "LFO 3 Global",
      },
      -- CURVE1
      [96] = {
        "Curve 1 Length", "Curve 1 Rate", "Curve 1 Sync Rate",
        "Curve 1 Stepped", "Curve 1 Tempo Sync", "Curve 1 OneShot",
        "Curve 1 Key Sync", "Curve 1 Bipolar", "Curve 1 Global",
      },
      -- CURVE2
      [127] = {
        "Curve 2 Length", "Curve 2 Rate", "Curve 2 Sync Rate",
        "Curve 2 Stepped", "Curve 2 Tempo Sync", "Curve 2 OneShot",
        "Curve 2 Key Sync", "Curve 2 Bipolar", "Curve 2 Global",
      },
    })
  },
  ripley = {
    ["Mod Source Tab"] = byParam({
      [0] = {
        "LFO1 Wave", "LFO1 Rate", "LFO1 Synced Rate", "LFO1 Phase", "LFO1 Sync",
        "LFO1 Mod1 Amt", "LFO1 Mod1 Amt2", "LFO1 Mod1 Scale Amt",
        "LFO1 Mod2 Amt", "LFO1 Mod2 Amt2", "LFO1 Mod2 Scale Amt",
        "LFO1 Mod3 Amt", "LFO1 Mod3 Amt2", "LFO1 Mod3 Scale Amt",
      },
      [42] = {
        "LFO2 Wave", "LFO2 Rate", "LFO2 Synced Rate", "LFO2 Phase", "LFO2 Sync",
        "LFO2 Mod1 Amt", "LFO2 Mod1 Amt2", "LFO2 Mod1 Scale Amt",
        "LFO2 Mod2 Amt", "LFO2 Mod2 Amt2", "LFO2 Mod2 Scale Amt",
        "LFO2 Mod3 Amt", "LFO2 Mod3 Amt2", "LFO2 Mod3 Scale Amt",
      },
      [85] = {
        "Follow Sensitivity", "Follow Rise", "Follow Fall", "Follow Source Select",
        "Follow Mod1 Amt", "Follow Mod1 Amt2", "Follow Mod1 Scale Amt",
        "Follow Mod2 Amt", "Follow Mod2 Amt2", "Follow Mod2 Scale Amt",
        "Follow Mod3 Amt", "Follow Mod3 Amt2", "Follow Mod3 Scale Amt",
      },
      [127] = {
        "Macro Button", "Macro Knob",
        "Matrix Mod1 Source", "Matrix Mod1 Amt", "Matrix Mod1 Amt2", "Matrix Mod1 Scale Amt",
        "Matrix Mod2 Source", "Matrix Mod2 Amt", "Matrix Mod2 Amt2", "Matrix Mod2 Scale Amt",
        "Matrix Mod3 Source", "Matrix Mod3 Amt", "Matrix Mod3 Amt2", "Matrix Mod3 Scale Amt",
      },
    })
  }
}
