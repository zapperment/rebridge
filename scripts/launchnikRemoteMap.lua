-- The Launchnik part of the Launchpad Pro [MK3] Remote maps: one line for each
-- of Launchnik's Remote items the codec uses, from "Map	deviceType" to the end
-- of the file. Launchnik has thousands of them, one for each setting of each
-- CV output of each clip and fill-in, so the lines are generated rather than
-- kept by hand; test/TestRemoteMaps.lua checks that the maps hold them.
--
-- Run from the root of the repository to rewrite both maps:
--   luajit scripts/launchnikRemoteMap.lua

local outputLetters = { "a", "b", "c", "d", "e", "f" }
local outputSettings = { "pattern", "unipolar", "bipolar", "transition" }

local function capitalise(word)
  return (word:gsub("^%l", string.upper))
end

local function launchnikMap()
  local lines = {}
  local function map(item, remotable)
    table.insert(lines, "Map\t" .. item .. "\t\t" .. remotable)
  end
  local function gap()
    table.insert(lines, "")
  end

  map("deviceType", '"launchnik"')
  map("deviceName", "Device Name")
  gap()
  map("setup", "Setup")
  map("switchinterval", "Switch Interval")
  map("fillin", "Fill-In")
  map("fillinlight", "Fill-In Light")
  map("setfillinlight", "Set Fill-In Light")
  map("function", "Function")

  -- a group of eight lines for each row, one for each track
  local function clipGroups(suffix, name)
    for row = 1, 8 do
      gap()
      for track = 1, 8 do
        map("track" .. track .. "clip" .. row .. suffix, "Track " .. track .. " Clip " .. row .. " " .. name)
      end
    end
  end
  local function trackGroup(suffix, name)
    gap()
    for track = 1, 8 do
      map("track" .. track .. suffix, "Track " .. track .. " " .. name)
    end
  end

  clipGroups("light", "Light")
  clipGroups("present", "Present")
  clipGroups("colour", "Colour")
  trackGroup("mute", "Mute")
  trackGroup("solo", "Solo")
  trackGroup("functionlight", "Function Light")
  gap()
  for scene = 1, 8 do
    map("scene" .. scene .. "light", "Scene " .. scene .. " Light")
  end
  trackGroup("selection", "Selection")
  clipGroups("fillinpresent", "Fill-In Present")
  clipGroups("fillincolour", "Fill-In Colour")

  -- the CV modes, a group of six for each track
  for track = 1, 8 do
    gap()
    for _, letter in ipairs(outputLetters) do
      map("track" .. track .. "cvmode" .. letter, "Track " .. track .. " Output " .. letter:upper() .. " CV Mode")
    end
  end

  -- the settings of the CV outputs of every clip and fill-in, a group of six
  -- for each launch button and setting
  for _, kind in ipairs({ { item = "", remotable = "" }, { item = "fillin", remotable = " Fill-In" } }) do
    for _, setting in ipairs(outputSettings) do
      for row = 1, 8 do
        for track = 1, 8 do
          gap()
          for _, letter in ipairs(outputLetters) do
            local item = "track" .. track .. "clip" .. row .. kind.item .. letter .. setting
            local remotable = "Track " .. track .. " Clip " .. row .. kind.remotable .. " Output " .. letter:upper() .. " " .. capitalise(setting)
            map(item, remotable)
          end
        end
      end
    end
  end

  return table.concat(lines, "\n") .. "\n"
end

local mapsDir = "src/reason/maps/novation/"
local start = "Map\tdeviceType"

-- the map with its Launchnik part replaced by the generated one
local function withLaunchnikMap(content)
  local plainFind = true
  local at = assert(string.find(content, start, 1, plainFind), "no Launchnik part in the map")
  return string.sub(content, 1, at - 1) .. launchnikMap()
end

if arg and arg[0] and arg[0]:match("launchnikRemoteMap%.lua$") then
  for _, name in ipairs({ "LPPMK3.remotemap", "LPPMK3.dev.remotemap" }) do
    local path = mapsDir .. name
    local file = assert(io.open(path, "r"))
    local content = file:read "*a"
    file:close()
    file = assert(io.open(path, "w"))
    file:write(withLaunchnikMap(content))
    file:close()
    print("Wrote " .. path)
  end
end

return {
  launchnikMap = launchnikMap,
  withLaunchnikMap = withLaunchnikMap,
}
