local tbl = require("src.lib.table._")

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

-- lists the given parameters of each of a player's patterns under the names
-- the host reports for them, e.g. "Steps" as "Pattern 1 Steps" … "Pattern 8 Steps"
local function patternParams(params)
  local names = {}
  for pattern = 1, 8 do
    for _, param in ipairs(params) do
      table.insert(names, "Pattern " .. pattern .. " " .. param)
    end
  end
  return names
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
      -- output section
      "Dry-Wet", "Output Gain",
    },
    green = {
      -- delay section
      "Delay Time", "Synced Time", "Delay Time L", "Synced Time L",
      "Delay Time R", "Synced Time R", "Time Offset L-R", "Delay On",
      "Feedback", "Time Multiplier", "Delay Width", "Feedback Limiter",
      -- eq section
      "EQ Low Gain", "EQ Mid Gain", "EQ Mid Q", "EQ Mid Frequency",
      "EQ High Gain", "EQ On", "EQ Position",
      -- matrix section
      "Macro Button", "Macro Knob",
    },
    mint = {
      -- matrix modulation
      "Matrix Mod1 Source", "Matrix Mod1 Amt", "Matrix Mod1 Amt2", "Matrix Mod1 Scale Amt",
      "Matrix Mod2 Source", "Matrix Mod2 Amt", "Matrix Mod2 Amt2", "Matrix Mod2 Scale Amt",
      "Matrix Mod3 Source", "Matrix Mod3 Amt", "Matrix Mod3 Amt2", "Matrix Mod3 Scale Amt",
    },
    yellow = {
      -- delay section (special because performance-relevant)
      "Freeze",
      -- LFO 1
      "LFO1 Wave", "LFO1 Rate", "LFO1 Synced Rate", "LFO1 Phase", "LFO1 Sync",

    },
    blue = {
      -- wobbler section
      "Wobbler Amount", "Wobbler On",
      -- ducker section
      "Ducker Amount", "Ducker On", "Ducker Position",
      -- LFO 2
      "LFO2 Wave", "LFO2 Rate", "LFO2 Synced Rate", "LFO2 Phase", "LFO2 Sync",
    },
    orange = {
      -- ping poing section
      "Ping Pong Pan", "Ping Pong",
      -- LFO 1 modulation
      "LFO1 Mod1 Amt", "LFO1 Mod1 Amt2", "LFO1 Mod1 Scale Amt",
      "LFO1 Mod2 Amt", "LFO1 Mod2 Amt2", "LFO1 Mod2 Scale Amt",
      "LFO1 Mod3 Amt", "LFO1 Mod3 Amt2", "LFO1 Mod3 Scale Amt",
    },
    violet = {
      -- space section
      "Space On", "Space Parallel", "Space Amount",
      "Space Decay", "Space Size", "Space Width",
    },
    pink = {
      -- filter section
      "Filter On", "Filter Type",
      -- follower mod section
      "Follow Mod1 Amt", "Follow Mod1 Amt2", "Follow Mod1 Scale Amt",
      "Follow Mod2 Amt", "Follow Mod2 Amt2", "Follow Mod2 Scale Amt",
      "Follow Mod3 Amt", "Follow Mod3 Amt2", "Follow Mod3 Scale Amt",
    },
    cyan = {
      -- noise section
      "Noise Amount", "Noise Character", "Noise High End", "Noise Type",
      "Noise On", "Noise Stereo", "Noise Position",
      -- LFO 2 modulation
      "LFO2 Mod1 Amt", "LFO2 Mod1 Amt2", "LFO2 Mod1 Scale Amt",
      "LFO2 Mod2 Amt", "LFO2 Mod2 Amt2", "LFO2 Mod2 Scale Amt",
      "LFO2 Mod3 Amt", "LFO2 Mod3 Amt2", "LFO2 Mod3 Scale Amt",
    },
    magenta = {
      -- dist section
      "Dist Dry-Wet", "Dist Tone", "Dist Drive",
      "Dist On", "Dist Position",
      -- follower section
      "Follow Sensitivity", "Follow Rise", "Follow Fall", "Follow Source Select",
    },
    amber = {
      -- digital section
      "Digital Dry-Wet", "Rate Crush", "Bit Crush",
      "Digital On", "Digital Position",
    }
  }),
  legend = byParam({
    red = {
      "Oscillator 1 Waveform",
      "Oscillator 1 Range",
      "Oscillator 1 Semi",
      "Oscillator 1 Fine",
      "Oscillator 1 Volume",
      "Oscillator 1 Active",
      "Unison Detune",
      "Unison Spread",
      "Polyphony",
      "Effects Active",
    },
    orange = {
      "Glide",
      "Modulation Mix",
      "Modulation Osc",
      "Modulation Filter",
    },
    yellow = {
      "Oscillator 3 Waveform",
      "Oscillator 3 Range",
      "Oscillator 3 Semi",
      "Oscillator 3 Fine",
      "Oscillator 3 Volume",
      "Oscillator 3 Active",
      "Oscillator 3 Keytrack",
    },
    violet = {
      "Noise Amount",
      "Noise Type",
      "Drive Amount",
      "Feedback Amount",
    },
    blue = {
      "Filter Cutoff",
      "Filter Resonance",
      "Filter Envelope Amount",
      "Filter Type",
      "Filter LP/BP",
      "Filter Keytrack 1",
      "Filter Keytrack 2",
      "Volume",
    },
    cyan = {
      "Oscillator 2 Waveform",
      "Oscillator 2 Range",
      "Oscillator 2 Semi",
      "Oscillator 2 Fine",
      "Oscillator 2 Volume",
      "Oscillator 2 Active",
    },
    green = {
      "Tuning Coarse",
      "Tuning Fine",
    }
  }),
  bassline = byParam({
    green = patternParams { -- OnBeat lane
      "OnBeat Bank", "OnBeat Source", "OnBeat Velocity", "OnBeat Note Length",
      "OnBeat Variator Shape", "OnBeat Variator Amount",
    },
    blue = patternParams { -- OffBeat lane
      "OffBeat Bank", "OffBeat Source", "OffBeat Velocity", "OffBeat Note Length",
      "OffBeat Variator Shape", "OffBeat Variator Amount",
    },
    amber = patternParams { -- rhythm and pitch of the pattern
      "Steps", "Shift", "Rate", "Shuffle",
    },
    -- pitch of the pattern
    magenta = tbl.concat(
      patternParams {
        "Root Note",
      },
      {
        "Octave", "MIDI Pitch", "MIDI Velocity", "Playback Mode",
      }
    ),
    cyan = patternParams { -- pitch of the pattern
      "Note Range", "Minorness"
    },
    red = { -- the device as a whole
      "On", "Run",
    },
  }),
  legendhz = byParam({
    red = {
      "Oscillator 1 Waveform",
      "Oscillator 1 Range",
      "Oscillator 1 Semi",
      "Oscillator 1 Fine",
      "Oscillator 1 Volume",
      "Oscillator 1 Active",

      "Glide", "Modulation Mix",
      "Modulation Osc", "Modulation Filter",
    },
    cyan = {
      "Oscillator 2 Waveform",
      "Oscillator 2 Range",
      "Oscillator 2 Semi",
      "Oscillator 2 Fine",
      "Oscillator 2 Volume",
      "Oscillator 2 Active",

      "ARP Octave", "ARP Sync", "ARP Rate",
      "ARP Length", "ARP Swing", "ARP Slide",

      "Tuning Coarse", "Tuning Fine",
    },
    yellow = {
      "Oscillator 3 Waveform",
      "Oscillator 3 Range",
      "Oscillator 3 Semi",
      "Oscillator 3 Fine",
      "Oscillator 3 Volume",
      "Oscillator 3 Active",
      "Oscillator 3 Keytrack",

      "Effects Active", "ARP Active",
      "Unison Detune", "Unison Spread", "Unison Mode",
      "Polyphony", "Volume"
    },
    orange = {
      "Oscillator 5 Waveform",
      "Oscillator 5 Range",
      "Oscillator 5 Semi",
      "Oscillator 5 Fine",
      "Oscillator 5 Volume",
      "Oscillator 5 Active",
    },
    mint = {
      "Oscillator 4 Waveform",
      "Oscillator 4 Range",
      "Oscillator 4 Semi",
      "Oscillator 4 Fine",
      "Oscillator 4 Volume",
      "Oscillator 4 Active",
    },
    green = {
      "Filter Envelope Attack",
      "Filter Envelope Decay",
      "Filter Envelope Sustain",
      "Filter Envelope Release",
    },
    violet = {
      "Noise Amount",
      "Noise Type",
      "Drive Amount",
      "Feedback Amount",
    },
    blue = {
      "Filter Cutoff",
      "Filter Resonance",
      "Filter Envelope Amount",
      "Filter Type",
      "Filter LP/BP",
      "Filter Keytrack 1",
      "Filter Keytrack 2",

      "Sustain Pedal", "Aftertouch",
      "Expression", "Breath Control",
    },
    sky = {
      "Oscillator 6 Waveform",
      "Oscillator 6 Range",
      "Oscillator 6 Semi",
      "Oscillator 6 Fine",
      "Oscillator 6 Volume",
      "Oscillator 6 Active",
      "Oscillator 6 Keytrack",
    },
    amber = {
      "Amplifier Envelope Attack",
      "Amplifier Envelope Decay",
      "Amplifier Envelope Sustain",
      "Amplifier Envelope Release",
    },
    magenta = {
      "MM #1 Amount", "MM #1 Mute",
      "MM #2 Amount", "MM #2 Mute",
      "MM #3 Amount", "MM #3 Mute",
      "MM #4 Amount", "MM #4 Mute",
      "MM #5 Amount", "MM #5 Mute",
      "MM #6 Amount", "MM #6 Mute",
      "MM #7 Amount", "MM #7 Mute",
      "MM #8 Amount", "MM #8 Mute",
      "MM #9 Amount", "MM #9 Mute",
      "MM #10 Amount", "MM #10 Mute",
      "MM #11 Amount", "MM #11 Mute",
      "MM #12 Amount", "MM #12 Mute",
    },
    pink = {
      "MSEG 1 Sync", "MSEG 1 Rate", "MSEG 1 Rate Sync",
      "MSEG 2 Sync", "MSEG 2 Rate", "MSEG 2 Rate Sync",
      "MSEG 3 Sync", "MSEG 3 Rate", "MSEG 3 Rate Sync",
      "MSEG 4 Sync", "MSEG 4 Rate", "MSEG 4 Rate Sync",
    },
  }),
}
