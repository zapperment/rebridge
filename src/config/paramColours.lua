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
    fhyd = { -- oscillator 1
      "Osc1 Wave", "Osc1 Octave", "Osc1 Semitone", "Osc1 Fine Tune",
      "Osc1 Phase Diff", "Osc1 Phase Mode", "Osc1 Kbd Track",
    },
    tang = { -- oscillator mix
      "FM Amount", "Osc Mix", "Ring Mod",
    },
    duri = { -- oscillator 2
      "Osc2 Wave", "Osc2 Octave", "Osc2 Semitone", "Osc2 Fine Tune",
      "Osc2 Phase Diff", "Osc2 Phase Mode", "Osc2 Kbd Track", "Osc2 On/Off",
    },
    poml = { -- noise
      "Noise On/Off", "Noise Level", "Noise Decay", "Noise Color",
    },
    tiff = { -- filter 1
      "Filter Freq", "Filter Res", "Filter Env Amount", "Filter Kbd Track",
      "Filter Env Invert", "Filter Type",
    },
    coco = { -- filter 2
      "Filter2 On/Off", "Filter Link Freq On/Off", "Filter2 Freq", "Filter2 Res",
    },
    plum = { -- LFO 1
      "LFO1 Rate", "LFO1 Amount", "LFO Sync Enable", "LFO1 Wave", "LFO1 Dest",
    },
    flam = { -- LFO 2
      "LFO2 Rate", "LFO2 Amount", "LFO2 Delay", "LFO2 Dest",
    },
    ceru = { -- performance and external modulation
      "Key Mode", "Portamento", "Low Bandwidth On/Off", "Polyphony",
      "Ext Mod Select", "Filter Freq Ext Mod", "LFO1 Ext Mod", "Amp Ext Mod",
      "FM Ext Mod",
    },
    suns = { -- pitch bend and mod wheel amounts
      "Pitch Bend Range", "Filter Freq Mod Wheel Amount",
      "Filter Res Mod Wheel Amount", "LFO1 Mod Wheel Amount",
      "Phase Diff Mod Wheel Amount", "FM Mod Wheel Amount",
    },
    aqua = { -- velocity amounts
      "Amp Vel Amount", "FM Vel Amount", "Mod Env Vel Amount",
      "Phase Vel Amount", "Filter2 Freq Vel Amount", "Filter Env Vel Amount",
      "Filter Decay Vel Amount", "Mix Vel Amount", "Amp Attack Vel Amount",
    },
  }),
}
