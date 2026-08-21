local lu = require "test.lib._".luaUnit
local controls = require "src.config.controls"

TestControls = {}

function TestControls:testAllLength()
    lu.assertEquals(
        #controls.all,
        #controls.encoders + #controls.faders + #controls.buttons + #controls.rackUIs,
        "all should contain every encoder, fader and button"
    )
end

function TestControls:testAllOrder()
    local expected = {}
    for _, group in ipairs { controls.encoders, controls.faders, controls.buttons, controls.rackUIs } do
        for _, name in ipairs(group) do
            table.insert(expected, name)
        end
    end
    lu.assertEquals(controls.all, expected, "all should list encoders, then faders, then buttons, then rack UIs")
end

function TestControls:testAllContainsSamples()
    local seen = {}
    for _, name in ipairs(controls.all) do
        seen[name] = true
    end
    lu.assertEquals(seen["encoder1"], true, "all should contain the first encoder")
    lu.assertEquals(seen["encoder1alt"], true, "all should contain the first alt encoder")
    lu.assertEquals(seen["fader1"], true, "all should contain the first fader")
    lu.assertEquals(seen["fader1alt"], true, "all should contain the first alt fader")
    lu.assertEquals(seen["button1"], true, "all should contain the first button")
    lu.assertEquals(seen["rackUI1"], true, "all should contain the first rack UI")
end

function TestControls:testAllIsACopy()
    table.insert(controls.all, "bogus")
    lu.assertEquals(controls.encoders[#controls.encoders], "encoder24alt",
        "mutating all should not affect the encoders table")
    table.remove(controls.all)
end
