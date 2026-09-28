local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lppmk3.config.constants"
local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"
local colours = require "src.lppmk3.lib.colour.config"
local makeColourEvent = require "src.lppmk3.lib.midi.makeColourEvent"
local processTransport = require "src.lppmk3.remote.processMidi.transport"
local setTransport = require "src.lppmk3.remote.setState.transport"
local deliverTransport = require "src.lppmk3.remote.deliverMidi.transport"
local defineItemIndices = require "test.lppmk3.defineItemIndices"

TestTransport = {}

-- the play button sends CC 20 on channel 1
local playButtonMidi = "b0 14 xx"

-- simulates the play button sending the given value
local function pressPlayButton(value)
  remote.mock "match_midi":impl(function(midi)
    if midi == playButtonMidi then
      return { x = value }
    end
    return nil
  end)
  return processTransport({ time_stamp = 0 })
end

-- simulates the host reporting the state of its Play remotable
local function reportPlaying(playing)
  remote.mock "get_item_state":impl(function()
    return { is_enabled = true, value = playing and 1 or 0 }
  end)
  setTransport({ items.playButton.index })
end

-- the item triggered by the only call of remote.handle_input
local function triggeredItem()
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1)
  lu.assertEquals(calls[1][1].value, 1)
  return calls[1][1].item
end

function TestTransport:setUp()
  remote.clearMocks()
  defineItemIndices()
  state.set("transport.playing", false)
  state.update "transport.playing"
end

function TestTransport:testPlayButtonStartsTransportWhenStopped()
  lu.assertTrue(pressPlayButton(127))
  lu.assertEquals(triggeredItem(), items.playButton.index)
end

function TestTransport:testPlayButtonStopsTransportWhenPlaying()
  reportPlaying(true)
  lu.assertTrue(pressPlayButton(127))
  lu.assertEquals(triggeredItem(), items.stopButton.index)
end

function TestTransport:testReleasingPlayButtonDoesNothing()
  lu.assertTrue(pressPlayButton(0))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestTransport:testIgnoresOtherMidi()
  remote.mock "match_midi":impl(function()
    return nil
  end)
  lu.assertFalse(processTransport({ time_stamp = 0 }))
end

function TestTransport:testRecordsPlayingState()
  reportPlaying(true)
  lu.assertTrue(state.get "transport.playing")
  reportPlaying(false)
  lu.assertFalse(state.get "transport.playing")
end

function TestTransport:testPlayButtonIsLitFromTheStart()
  local StateManager = require "src.lppmk3.lib.state.StateManager"
  lu.assertTrue(StateManager:new():hasChanged "transport.playing")
end

function TestTransport:testPlayButtonIsDimAndStaticWhenStopped()
  reportPlaying(true)
  state.update "transport.playing"
  reportPlaying(false)
  lu.assertEquals(deliverTransport(), { makeColourEvent(20, colours.green.dim) })
end

function TestTransport:testPlayButtonIsBrightAndPulsingWhenPlaying()
  reportPlaying(true)
  lu.assertEquals(deliverTransport(), {
    makeColourEvent(20, colours.green.vibrant, const.colourBehaviour.pulsing),
  })
end

function TestTransport:testDeliversNothingWhenTransportUnchanged()
  lu.assertEquals(deliverTransport(), {})
end
