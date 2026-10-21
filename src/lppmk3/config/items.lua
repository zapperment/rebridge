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
-- editing
items.setup = { input = "value", output = "value", min = 0, max = 129, launchnik = { kind = "setup" } }

-- the length of the switch interval: 0 = immediate, 1 = one beat, 2 = half a
-- bar, 3..7 = 1, 2, 4, 8 and 16 bars
items.switchinterval = { input = "value", min = 0, max = 7 }

-- 1 while the fill-in button is held down, 0 once it is let go
items.fillin = { input = "value", min = 0, max = 1 }
-- what the function buttons do: 0 = stop, 1 = mute, 2 = solo
items["function"] = { input = "value", output = "value", min = 0, max = 2, launchnik = { kind = "function" } }

-- the lights of the fill-in button and the set fill-in button, encoded like
-- the light of a launch button
items.fillinlight = { output = "value", min = 0, max = 42, launchnik = { kind = "fillinlight" } }
items.setfillinlight = { output = "value", min = 0, max = 42, launchnik = { kind = "setfillinlight" } }

-- the CV outputs A to F of each track, as in Launchnik's Remote items
local outputLetters = { "a", "b", "c", "d", "e", "f" }

-- the settings of a CV output of a clip or a fill-in, and their ranges: eight
-- patterns, seven unipolar or bipolar values, five transitions (off, A to D)
local outputSettings = {
  { name = "pattern", max = 7 },
  { name = "unipolar", max = 6 },
  { name = "bipolar", max = 6 },
  { name = "transition", max = 4 },
}

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
  -- 0 stops the track, 1 to 8 select the clip in that row
  items["track" .. track .. "selection"] = { input = "value", min = 0, max = 8 }

  for row = 1, 8 do
    local clip = "track" .. track .. "clip" .. row
    local index = (track - 1) * 8 + (row - 1)
    -- 0 = unlit, then dim, vibrant and flashing for each of the 14 colours
    items[clip .. "light"] = { output = "value", min = 0, max = 42, launchnik = { kind = "light", index = index } }
    items[clip .. "present"] = { input = "value", output = "value", min = 0, max = 1, launchnik = { kind = "present", index = index } }
    items[clip .. "colour"] = { input = "value", min = 0, max = 13 }
    items[clip .. "fillinpresent"] = { input = "value", output = "value", min = 0, max = 1, launchnik = { kind = "fillinpresent", index = index } }
    items[clip .. "fillincolour"] = { input = "value", min = 0, max = 13 }
    -- the settings of the CV outputs, for example track1clip1apattern and
    -- track1clip1fillinapattern; the codec reads the clip's, which a new
    -- fill-in starts as a copy of, and the transitions, which a press moves on
    for output, letter in ipairs(outputLetters) do
      for _, setting in ipairs(outputSettings) do
        items[clip .. letter .. setting.name] = { input = "value", output = "value", min = 0, max = setting.max, launchnik = { kind = setting.name, index = index, output = output } }
        local fillIn = { input = "value", min = 0, max = setting.max }
        if setting.name == "transition" then
          fillIn.output = "value"
          fillIn.launchnik = { kind = "fillintransition", index = index, output = output }
        end
        items[clip .. "fillin" .. letter .. setting.name] = fillIn
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
