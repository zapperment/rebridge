local test = require "test.lib._"
local lu = test.luaUnit
local colours = require "src.lppmk3.lib.colour.config"
local makeColourEvent = require "src.lppmk3.lib.midi.makeColourEvent"
local padsOff = require "src.lppmk3.remote.deliverMidi.padsOff"

TestPadsOff = {}

function TestPadsOff:testTurnsOffEveryPadSceneButtonAndTheBackButton()
    local expected = {}
    for row = 8, 1, -1 do
        for column = 1, 9 do
            table.insert(expected, makeColourEvent(row * 10 + column, colours.off))
        end
    end
    table.insert(expected, makeColourEvent(91, colours.off))
    lu.assertEquals(padsOff(), expected)
end
