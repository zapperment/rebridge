local items = {
  deviceType = { output = "text" },
  deviceName = { output = "text" },
  playButton = { input = "button", output = "value", min = 0, max = 127, midi = "b0 14 xx", controller = 20 },
  stopButton = { input = "button", output = "value", min = 0, max = 127 },
  recordButton = { input = "button", output = "value", min = 0, max = 127, midi = "b0 0a xx", controller = 10 },
}

-- The items of Launchnik follow, named after its Remote items. The host
-- scales an item's range onto the remotable's, so each range has to be that of
-- the remotable for the values to arrive unchanged. The launchnik entry says
-- what the item stands for; a launch button's index is 0..63, counted down
-- track 1 first.

-- 0 = launch mode, 1 = clip picking, 2..65 = clip editing, 66..129 = fill-in
-- editing, 130..193 = landing editing, 194..257 = intro editing, 258..321 =
-- outro editing, 322 = clear mode, 323 = source picking, 324..387 =
-- destination picking for a launch button and 388..395 for a scene as the
-- source
items.setup = { input = "value", output = "value", min = 0, max = 395, launchnik = { kind = "setup" } }

-- the length of the switch interval: 0 = immediate, 1 = one beat, 2 = half a
-- bar, 3..7 = 1, 2, 4, 8 and 16 bars
items.switchinterval = { input = "value", min = 0, max = 7 }

-- 1 while the fill-in button is held down, 0 once it is let go
items.fillin = { input = "value", min = 0, max = 1 }
-- what the function buttons do: 0 = stop, 1 = mute, 2 = solo
items["function"] = { input = "value", output = "value", min = 0, max = 2, launchnik = { kind = "function" } }

-- the lights of the fill-in button and the forward button, encoded like the
-- light of a launch button
items.fillinlight = { output = "value", min = 0, max = 42, launchnik = { kind = "fillinlight" } }
items.forwardlight = { output = "value", min = 0, max = 42, launchnik = { kind = "forwardlight" } }

-- the CV outputs A to F of each track, as in Launchnik's Remote items
local outputLetters = { "a", "b", "c", "d", "e", "f" }

-- the settings of a CV output of a clip, a fill-in, a landing, an intro or an
-- outro, all four in one item (see Launchnik's ADR 0008): eight patterns,
-- seven unipolar values, seven bipolar values and five transitions (off, A
-- to D), 1960 values in all
local outputSettingsMax = 8 * 7 * 7 * 5 - 1

for track = 1, 8 do
  -- the CV mode of each CV output: 0 = bipolar, 1 = unipolar, 2 = pattern; the
  -- codec only reads it, to tell what a press in clip editing means
  for output, letter in ipairs(outputLetters) do
    items["track" .. track .. "cvmode" .. letter] = { output = "value", min = 0, max = 2, launchnik = { kind = "cvmode", track = track, output = output } }
  end

  -- the light of the track's function button, in the colour of the function:
  -- 0 = unlit, 1 = dim, 2 = vibrant, 3 = flashing
  items["track" .. track .. "functionlight"] = { output = "value", min = 0, max = 3, launchnik = { kind = "functionlight", track = track } }
  -- 1 while the track's mute or solo button is held down, 0 once it is let go
  items["track" .. track .. "mute"] = { input = "value", min = 0, max = 1 }
  items["track" .. track .. "solo"] = { input = "value", min = 0, max = 1 }
  -- 1 while a launch on the track is held down, 0 once it is let go
  items["track" .. track .. "relaunch"] = { input = "value", min = 0, max = 1 }
  -- 0 stops the track, 1 to 8 select the clip in that row
  items["track" .. track .. "selection"] = { input = "value", min = 0, max = 8 }

  for row = 1, 8 do
    local clip = "track" .. track .. "clip" .. row
    local index = (track - 1) * 8 + (row - 1)
    -- 0 = unlit, then dim, vibrant and flashing for each of the 14 colours
    items[clip .. "light"] = { output = "value", min = 0, max = 42, launchnik = { kind = "light", index = index } }
    items[clip .. "present"] = { input = "value", output = "value", min = 0, max = 1, launchnik = { kind = "present", index = index } }
    items[clip .. "colour"] = { input = "value", output = "value", min = 0, max = 13, launchnik = { kind = "colour", index = index } }
    items[clip .. "fillinpresent"] = { input = "value", output = "value", min = 0, max = 1, launchnik = { kind = "fillinpresent", index = index } }
    items[clip .. "fillincolour"] = { input = "value", output = "value", min = 0, max = 13, launchnik = { kind = "fillincolour", index = index } }
    items[clip .. "fillinonebarpattern"] = { input = "value", output = "value", min = 0, max = 1, launchnik = { kind = "fillinonebarpattern", index = index } }
    items[clip .. "landingpresent"] = { input = "value", output = "value", min = 0, max = 1, launchnik = { kind = "landingpresent", index = index } }
    items[clip .. "landingcolour"] = { input = "value", output = "value", min = 0, max = 13, launchnik = { kind = "landingcolour", index = index } }
    items[clip .. "landingonebarpattern"] = { input = "value", output = "value", min = 0, max = 1, launchnik = { kind = "landingonebarpattern", index = index } }
    for _, overlay in ipairs({ "intro", "outro" }) do
      items[clip .. overlay .. "present"] = { input = "value", output = "value", min = 0, max = 1, launchnik = { kind = overlay .. "present", index = index } }
      items[clip .. overlay .. "colour"] = { input = "value", output = "value", min = 0, max = 13, launchnik = { kind = overlay .. "colour", index = index } }
      items[clip .. overlay .. "onebarpattern"] = { input = "value", output = "value", min = 0, max = 1, launchnik = { kind = overlay .. "onebarpattern", index = index } }
    end
    -- the settings of the CV outputs, for example track1clip1a,
    -- track1clip1fillina, track1clip1landinga, track1clip1introa and
    -- track1clip1outroa; the codec reads them all: the clip's, which a new
    -- fill-in, landing, intro or outro starts as a copy of, those being
    -- edited, which a press keeps all but one of, and everything, which a
    -- duplicate copies
    for output, letter in ipairs(outputLetters) do
      for _, prefix in ipairs({ "", "fillin", "landing", "intro", "outro" }) do
        items[clip .. prefix .. letter] = { input = "value", output = "value", min = 0, max = outputSettingsMax, launchnik = { kind = prefix .. "output", index = index, output = output } }
      end
    end
  end
end

for scene = 1, 8 do
  -- the light of the scene button: its part of the interval meter, or in clip
  -- picking the length it stands for; encoded like the light of a launch button
  items["scene" .. scene .. "light"] = { output = "value", min = 0, max = 42, launchnik = { kind = "scenelight", scene = scene } }
end

return items
