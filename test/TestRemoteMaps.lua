local test = require "test.lib._"
local lu = test.luaUnit

TestRemoteMaps = {}

local mapsDir = "src/reason/maps/novation/"

local function read(path)
    local file = assert(io.open(path, "r"))
    local content = file:read "*a"
    file:close()
    return content
end

-- the non-developer map of each controller has the same mappings as the
-- developer map, which is the one used while developing, so that it cannot
-- fall behind; only the model differs
local function assertMapsMatch(controller, model)
    local devMap = read(mapsDir .. controller .. ".dev.remotemap")
    local map = read(mapsDir .. controller .. ".remotemap")
    local devModelLine = "Control Surface Model\t" .. model .. " (developer version)\n"
    local modelLine = "Control Surface Model\t" .. model .. "\n"
    lu.assertStrContains(devMap, devModelLine)
    lu.assertStrContains(map, modelLine)
    local plainFind = true
    local start, finish = string.find(devMap, devModelLine, 1, plainFind)
    lu.assertEquals(map, string.sub(devMap, 1, start - 1) .. modelLine .. string.sub(devMap, finish + 1))
end

function TestRemoteMaps:testLaunchControlMapsMatch()
    assertMapsMatch("LCXL3", "Launch Control XL3")
end

function TestRemoteMaps:testLaunchpadMapsMatch()
    assertMapsMatch("LPPMK3", "Launchpad Pro [MK3]")
end

-- the Launchnik part of the Launchpad map is generated, and maps every item
-- of the codec that stands for one of Launchnik's Remote items
function TestRemoteMaps:testLaunchnikMapIsGenerated()
    local launchnikMap = require "scripts.launchnikRemoteMap"
    local devMap = read(mapsDir .. "LPPMK3.dev.remotemap")
    lu.assertEquals(devMap, launchnikMap.withLaunchnikMap(devMap))
end

function TestRemoteMaps:testLaunchnikMapUsesTheCodecsItems()
    local items = require "src.lppmk3.config.items"
    local devMap = read(mapsDir .. "LPPMK3.dev.remotemap")
    local mapped = {}
    for item in string.gmatch(devMap, "\nMap\t(%w+)\t") do
        lu.assertNotNil(items[item], item)
        mapped[item] = true
    end
    for name, item in pairs(items) do
        if item.launchnik or item.input == "value" then
            lu.assertTrue(mapped[name] == true, name)
        end
    end
end
