local test = require "test.lib._"
local lu = test.luaUnit
local colours = require "src.lppcommon.lib.colour.config"
local makePadsOff = require "src.lppcommon.remote.deliverMidi.padsOff"

-- defines the test class TestPadsOff<suffix> for the device given (see
-- src/lppmk3/device.lua)
return function(device, suffix)
  local TestPadsOff = {}
  _G["TestPadsOff" .. suffix] = TestPadsOff

  local c = device.controls
  local makeColourEvent = device.midi.makeColourEvent
  local padsOff = makePadsOff(device)

  function TestPadsOff:testTurnsOffEveryPadSceneButtonAndTheButtonsAroundTheGrid()
    local expected = {}
    for row = 8, 1, -1 do
      for column = 1, 9 do
        table.insert(expected, makeColourEvent(row * 10 + column, colours.off))
      end
    end
    table.insert(expected, makeColourEvent(c.back, colours.off))
    table.insert(expected, makeColourEvent(c.forward, colours.off))
    table.insert(expected, makeColourEvent(c.fillIn, colours.off))
    if c.setup then
      table.insert(expected, makeColourEvent(c.setup, colours.off))
    end
    lu.assertEquals(padsOff(), expected)
  end
end
