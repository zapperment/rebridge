-- Parameters that cycle through their values when the button they are mapped
-- to is pressed, mirroring the momentary buttons on the device's own UI (e.g.
-- SubTractor's Phase Mode button steps through the three phase modes). Keyed
-- by device type, then by parameter name; the value is the number of values
-- the parameter can take, from the tables in "Reason Remote Support.pdf"
-- (number of values = max + 1).
--
-- A two-value parameter is normally a toggle and does not belong here; list it
-- only if its button should step like the device's own, as the Bassline
-- Generator's Bank buttons do, which step between bank A and bank B.

-- lists the given parameter of each of a player's patterns under the names the
-- host reports for them, e.g. "OnBeat Bank" as "Pattern 1 OnBeat Bank" …
local function forEachPattern(params, count)
  local cycleParams = {}
  for pattern = 1, 8 do
    for _, param in ipairs(params) do
      cycleParams["Pattern " .. pattern .. " " .. param] = count
    end
  end
  return cycleParams
end

return {
  subtractor = {
    ["Osc1 Phase Mode"] = 3,
    ["Osc2 Phase Mode"] = 3,
    ["Filter Type"] = 5,
    ["LFO1 Wave"] = 6,
    ["LFO1 Dest"] = 6,
    ["LFO2 Dest"] = 4,
    ["Mod Env Dest"] = 6,
    ["Ext Mod Select"] = 3,
  },
  algoritm = {
    ["Mode1"] = 5,
    ["Mode2"] = 5,
    ["Mode3"] = 5,
    ["Mode4"] = 5,
    ["Mode5"] = 5,
    ["Mode6"] = 5,
    ["Mode7"] = 5,
    ["Mode8"] = 5,
    ["Mode9"] = 5,
    ["Unison Count"] = 3,
    ["Dist Type"] = 6,
    ["Mod Effect Type"] = 3,
    ["Resonator Select"] = 21,
    ["Key Mode"] = 3,
    ["Portamento Mode"] = 3,
  },
  ripley = {
    ["Enabled"] = 3,
    ["Time Multiplier"] = 3,
    ["Filter Type"] = 2,
    ["Noise Position"] = 5,
    ["Dist Position"] = 5,
    ["Digital Position"] = 5,
    ["EQ Position"] = 5,
    ["Ducker Position"] = 3,
    ["Follow Source Select"] = 5,
    ["Matrix Mod1 Source"] = 10,
    ["Matrix Mod2 Source"] = 10,
    ["Matrix Mod3 Source"] = 10,
  },
  bassline = (function()
    local params = forEachPattern({ "OnBeat Bank", "OffBeat Bank" }, 2)
    params["Playback Mode"] = 3
    return params
  end)(),
  polystep = {
    ["Midi Transpose"] = 3,
  },
  polytone = {
    ["Osc 1 Wave A"] = 6,
    ["Osc 2 Wave A"] = 6,
    ["Portamento Mode A"] = 3,
    ["LFO Wave A"] = 7,
    ["Osc 1 Wave B"] = 6,
    ["Osc 2 Wave B"] = 6,
    ["Portamento Mode B"] = 3,
    ["LFO Wave B"] = 7,
    ["Layer Mode"] = 3,
    ["Balance Mod"] = 4,
    ["Key Mode"] = 3,
    ["Global LFO Dest"] = 8,
    ["Global LFO Wave"] = 7,
    ["Chorus Type"] = 3,
    ["Reverb Type"] = 3,
  }
}
