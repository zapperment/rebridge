-- The colour of the LED of the encoder or button a parameter is mapped to,
-- grouped by the sections of the device's own panel so that related controls
-- light up alike. Keyed by the device type (as mapped to a name in the remote
-- map), then by the colour, listing the parameters that take it.
--
-- A device type that is not listed here, or a parameter that its list does not
-- name, keeps the default colour of the control it is mapped to (see
-- config/items). The faders have no colour, as they have no LEDs.

-- turns the colour-to-parameters lists into the parameter-to-colour lookup the
-- codec needs
local function byParam(groups)
  local colours = {}
  for colour, params in pairs(groups) do
    for _, param in ipairs(params) do
      colours[param] = colour
    end
  end
  return colours
end

return {
  subtractor = byParam({
    red = { -- oscillator 1
      "Osc1 Wave", "Osc1 Octave", "Osc1 Semitone", "Osc1 Fine Tune",
      "Osc1 Phase Diff", "Osc1 Phase Mode", "Osc1 Kbd Track",
    },
    cyan = { -- oscillator mix
      "FM Amount", "Osc Mix", "Ring Mod",
    },
    yellow = { -- oscillator 2
      "Osc2 Wave", "Osc2 Octave", "Osc2 Semitone", "Osc2 Fine Tune",
      "Osc2 Phase Diff", "Osc2 Phase Mode", "Osc2 Kbd Track", "Osc2 On/Off",
    },
    green = { -- noise
      "Noise On/Off", "Noise Level", "Noise Decay", "Noise Color",
    },
    orange = { -- filter 1
      "Filter Freq", "Filter Res", "Filter Env Amount", "Filter Kbd Track",
      "Filter Env Invert", "Filter Type",
    },
    blue = { -- filter 2
      "Filter2 On/Off", "Filter Link Freq On/Off", "Filter2 Freq", "Filter2 Res",
    },
    violet = { -- LFO 1
      "LFO1 Rate", "LFO1 Amount", "LFO Sync Enable", "LFO1 Wave", "LFO1 Dest",
    },
    magenta = { -- LFO 2
      "LFO2 Rate", "LFO2 Amount", "LFO2 Delay", "LFO2 Dest", "LFO2 Kbd Track"
    },
    amber = { -- performance and external modulation
      "Portamento",
      "Polyphony",
      "Key Mode", "Low Bandwidth On/Off",
      "Pitch Bend Range",
    },
    pink = {
      "Ext Mod Select", "Filter Freq Ext Mod", "LFO1 Ext Mod", "Amp Ext Mod",
      "FM Ext Mod",
    },
    sky = { -- pitch bend and mod wheel amounts
      "Filter Freq Mod Wheel Amount",
      "Filter Res Mod Wheel Amount", "LFO1 Mod Wheel Amount",
      "Phase Diff Mod Wheel Amount", "FM Mod Wheel Amount",
    },
    mint = { -- velocity amounts & mod env
      "Amp Vel Amount", "FM Vel Amount",
      "Phase Vel Amount", "Filter2 Freq Vel Amount", "Filter Env Vel Amount",
      "Filter Decay Vel Amount", "Mix Vel Amount", "Amp Attack Vel Amount",
      "Mod Env Vel Amount",
      "Mod Env Gain",
      "Mod Env Invert",
      "Mod Env Dest",
    },
  }),
  algoritm = byParam({
    sky = {
      "Reverb Decay", "Reverb Size", "Reverb Damp", "Reverb Early Reflections", "Reverb On",
      "Feedback", "Osc Sync",
      "Curve 2 Length", "Curve 2 Rate", "Curve 2 Sync Rate", "Curve 2 Stepped", "Curve 2 Tempo Sync", "Curve 2 OneShot",
      "Curve 2 Key Sync", "Curve 2 Bipolar", "Curve 2 Global",
    },
    yellow = {
      "Delay Time", "Delay Synced Time", "Delay Feedback", "Delay Pan", "Delay Sync", "Delay PingPong", "Delay On",
      "Portamento", "Portamento Mode"
    },
    cyan = {
      "Dist Drive", "Dist Tone", "Dist Type", "Dist On"
    },
    orange = {
      "Comp Attack", "Comp Release", "Comp Threshold", "Comp On",
      "LFO 1 Wave", "LFO 1 Rate", "LFO 1 Sync Rate", "LFO 1 Delay", "LFO 1 Tempo Sync", "LFO 1 Key Sync", "LFO 1 Global",
    },
    violet = {
      "Mod Effect Depth", "Mod Effect Rate", "Mod Effect Spread", "Mod Effect Feedback", "Mod Effect Type", "Phaser On",
      "Octave",
      "LFO 2 Wave", "LFO 2 Rate", "LFO 2 Sync Rate", "LFO 2 Delay", "LFO 2 Tempo Sync", "LFO 2 Key Sync", "LFO 2 Global",
    },
    green = {
      "Resonator Pitch", "Resonator Decay", "Resonator Width", "Resonator Mix", "Resonator Select", "Resonator On",
      "FM Key Scale", "Rate Key Scale"
    },
    blue = {
      "EQ Freq", "EQ Q", "EQ On",
      "Pitch Bend Range", "Key Mode",
    },
    red = {
      "Unison Timing", "Unison Detune", "Unison Spread", "Unison Blend", "Unison Count", "Unison On",
      "Curve 1 Length", "Curve 1 Rate", "Curve 1 Sync Rate", "Curve 1 Stepped", "Curve 1 Tempo Sync", "Curve 1 OneShot",
      "Curve 1 Key Sync", "Curve 1 Bipolar", "Curve 1 Global",
    },
    mint = {
      "FM Amount Offset", "Decay/Release Offset",
      "LFO 3 Wave", "LFO 3 Rate", "LFO 3 Sync Rate", "LFO 3 Delay", "LFO 3 Tempo Sync", "LFO 3 Key Sync", "LFO 3 Global",
    },
  }),
  ripley = byParam({
    red = {
      -- main section
      "Enabled",
      "Delay Tempo Sync", "Keep Pitch", "Dual Delay",
    },
    green = {
      -- delay section
      "Delay Time", "Synced Time", "Delay Time L", "Synced Time L",
      "Delay Time R", "Synced Time R", "Time Offset L-R", "Delay On",
      "Feedback", "Time Multiplier", "Delay Width", "Feedback Limiter"
    },
    yellow = {
      -- delay section (special because performance-relevant)
      "Freeze",
    },
    blue = {
      -- wobbler section
      "Wobbler Amount", "Wobbler On",
    },
    orange = {
      -- ping poing section
      "Ping Pong Pan", "Ping Pong",
    },
    violet = {
      -- space section
      "Space On", "Space Parallel", "Space Amount",
      "Space Decay", "Space Size", "Space Width",
    },
    pink = {
      -- filter section
      "Filter On", "Filter Type",
    }
  })
}
