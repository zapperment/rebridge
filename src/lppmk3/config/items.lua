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
-- the lights of the fill-in button and the set fill-in button, encoded like
-- the light of a launch button
items.fillinlight = { output = "value", min = 0, max = 42, launchnik = { kind = "fillinlight" } }
items.setfillinlight = { output = "value", min = 0, max = 42, launchnik = { kind = "setfillinlight" } }

for track = 1, 8 do
  -- the light of the track's stop button: 0 = unlit, 1 = dim, 2 = vibrant,
  -- 3 = flashing
  items["track" .. track .. "stoplight"] = { output = "value", min = 0, max = 3, launchnik = { kind = "stoplight", track = track } }
  -- 0 stops the track, 1 to 8 select the clip in that row
  items["track" .. track .. "selection"] = { input = "value", min = 0, max = 8 }

  for row = 1, 8 do
    local clip = "track" .. track .. "clip" .. row
    local index = (track - 1) * 8 + (row - 1)
    -- 0 = unlit, then dim, vibrant and flashing for each of the 14 colours
    items[clip .. "light"] = { output = "value", min = 0, max = 42, launchnik = { kind = "light", index = index } }
    items[clip .. "present"] = { input = "value", output = "value", min = 0, max = 1, launchnik = { kind = "present", index = index } }
    -- the clip's pattern is what a new fill-in starts with
    items[clip .. "pattern"] = { input = "value", output = "value", min = 0, max = 7, launchnik = { kind = "pattern", index = index } }
    items[clip .. "colour"] = { input = "value", min = 0, max = 13 }
    items[clip .. "fillinpresent"] = { input = "value", output = "value", min = 0, max = 1, launchnik = { kind = "fillinpresent", index = index } }
    items[clip .. "fillinpattern"] = { input = "value", min = 0, max = 7 }
    items[clip .. "fillincolour"] = { input = "value", min = 0, max = 13 }
  end
end

for scene = 1, 8 do
  -- the light of the scene button: its part of the interval meter, or in clip
  -- picking the length it stands for; encoded like the light of a launch button
  items["scene" .. scene .. "light"] = { output = "value", min = 0, max = 42, launchnik = { kind = "scenelight", scene = scene } }
end

return items
