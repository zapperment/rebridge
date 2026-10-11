local items = {
  deviceType = { output = "text" },
  deviceName = { output = "text" },
  playButton = { input = "button", output = "value", min = 0, max = 127, midi = "b0 14 xx", controller = 20 },
  stopButton = { input = "button", output = "value", min = 0, max = 127 },
  recordButton = { input = "button", output = "value", min = 0, max = 127, midi = "b0 0a xx", controller = 10 },
}

for pad = 1, 64 do
  items["pad" .. pad .. "led"] = { output = "value", min = 0, max = 2 }
end

for track = 1, 8 do
  items["trackButton" .. track .. "led"] = { output = "value", min = 0, max = 2 }
  -- 0 stops the track, 1 to 8 select one of its patterns
  items["track" .. track .. "slot"] = { input = "value", min = 0, max = 8 }
end

-- THROWAWAY: the Remote items of the Launchnik Spike device, see src/lppmk3/spike
items.spikeClipPresent = { input = "value", output = "value", min = 0, max = 1 }
items.spikeClipColour = { input = "value", output = "value", min = 0, max = 13 }
items.spikeSetup = { input = "value", output = "value", min = 0, max = 65 }
items.spikeLight = { output = "value", min = 0, max = 28 }

return items
