local test = require "test.lib._"
local lu = test.luaUnit
local items = require "src.lppmk3.config.items"
local processTrackSlots = require "src.lppmk3.remote.processMidi.trackSlots"
local defineItemIndices = require "test.lppmk3.defineItemIndices"

TestProcessTrackSlots = {}

local noteOn = 144
local controlChange = 176

-- simulates the remote surface sending the given MIDI message
local function receive(status, data1, data2)
  remote.mock "match_midi":impl(function()
    return { x = status, y = data1, z = data2 }
  end)
  return processTrackSlots({ time_stamp = 0 })
end

-- the input passed to the only call of remote.handle_input
local function handledInput()
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1)
  return calls[1][1]
end

function TestProcessTrackSlots:setUp()
  remote.clearMocks()
  defineItemIndices()
end

-- the host scales an item's range onto the remotable's, so the range has to
-- be that of Launchnik's "Track N Selection" for the slots to arrive unchanged
function TestProcessTrackSlots:testSlotItemsCoverStopAndEightPatterns()
  for track = 1, 8 do
    local item = items["track" .. track .. "slot"]
    lu.assertEquals(item.min, 0)
    lu.assertEquals(item.max, 8)
  end
end

function TestProcessTrackSlots:testTopLeftPadSelectsPattern1OfTrack1()
  lu.assertTrue(receive(noteOn, 81, 127))
  local input = handledInput()
  lu.assertEquals(input.item, items.track1slot.index)
  lu.assertEquals(input.value, 1)
end

function TestProcessTrackSlots:testBottomRightPadSelectsPattern8OfTrack8()
  lu.assertTrue(receive(noteOn, 18, 127))
  local input = handledInput()
  lu.assertEquals(input.item, items.track8slot.index)
  lu.assertEquals(input.value, 8)
end

function TestProcessTrackSlots:testEveryPadSelectsItsRowOfItsColumn()
  for row = 1, 8 do
    for column = 1, 8 do
      remote.clearMocks()
      receive(noteOn, (9 - row) * 10 + column, 127)
      local input = handledInput()
      lu.assertEquals(input.item, items["track" .. column .. "slot"].index)
      lu.assertEquals(input.value, row)
    end
  end
end

function TestProcessTrackSlots:testTrackButtonStopsItsTrack()
  lu.assertTrue(receive(controlChange, 103, 127))
  local input = handledInput()
  lu.assertEquals(input.item, items.track3slot.index)
  lu.assertEquals(input.value, 0)
end

function TestProcessTrackSlots:testReleasingPadDoesNothing()
  lu.assertFalse(receive(noteOn, 81, 0))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessTrackSlots:testIgnoresOtherControlChanges()
  lu.assertFalse(receive(controlChange, 90, 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end
