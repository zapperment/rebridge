local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lpcommon.config.constants"
local items = require "src.lpcommon.config.items"
local state = require "src.lpcommon.lib.state._"
local colours = require "src.lpcommon.lib.colour.config"
local surface = require "src.lpcommon.lib.surface._"
local makeProcessTransport = require "src.lpcommon.remote.processMidi.transport"
local setTransport = require "src.lpcommon.remote.setState.transport"
local makeDeliverTransport = require "src.lpcommon.remote.deliverMidi.transport"
local defineItemIndices = require "test.lpcommon.defineItemIndices"

-- defines the test class TestTransport<suffix> for the device given (see
-- src/lppmk3/device.lua)
return function(device, suffix)
  local TestTransport = {}
  _G["TestTransport" .. suffix] = TestTransport

  local c = device.controls
  -- the codec works out lights, which only become MIDI events on their way
  -- through the Shift layer
  local makeColourEvent = surface.makeLight
  local processTransport = makeProcessTransport(device)
  local deliverTransport = makeDeliverTransport(device)

  -- simulates the given button being pressed, or let go with value 0, as
  -- remote/processMidi/surface.lua hands it on
  local function pressButton(control, value)
    return processTransport({ time_stamp = 0, control = control, value = value, pad = false })
  end

  local function pressPlayButton(value)
    return pressButton(c.play, value)
  end

  local function pressRecordButton(value)
    return pressButton(c.record, value)
  end

  -- simulates the host reporting the state of the remotable mapped to the given
  -- button
  local function report(button, on)
    remote.mock "get_item_state":impl(function()
      return { is_enabled = true, value = on and 1 or 0 }
    end)
    setTransport({ items[button].index })
  end

  local function reportPlaying(playing)
    report("playButton", playing)
  end

  local function reportRecording(recording)
    report("recordButton", recording)
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
    state.set("transport.recording", false)
    state.update "transport.recording"
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
    lu.assertFalse(pressButton(c.shift, 127))
    -- a pad is not a button, whatever its number
    lu.assertFalse(processTransport({ time_stamp = 0, control = c.play, value = 127, pad = true }))
  end

  function TestTransport:testRecordsPlayingState()
    reportPlaying(true)
    lu.assertTrue(state.get "transport.playing")
    reportPlaying(false)
    lu.assertFalse(state.get "transport.playing")
  end

  function TestTransport:testPlayAndRecordButtonsAreLitFromTheStart()
    local StateManager = require "src.lpcommon.lib.state.StateManager"
    local stateManager = StateManager:new()
    lu.assertTrue(stateManager:hasChanged "transport.playing")
    lu.assertTrue(stateManager:hasChanged "transport.recording")
  end

  function TestTransport:testPlayButtonIsDimAndStaticWhenStopped()
    reportPlaying(true)
    state.update "transport.playing"
    reportPlaying(false)
    lu.assertEquals(deliverTransport(), { makeColourEvent(c.play, colours.green.dim) })
  end

  function TestTransport:testPlayButtonIsBrightAndPulsingWhenPlaying()
    reportPlaying(true)
    lu.assertEquals(deliverTransport(), {
      makeColourEvent(c.play, colours.green.vibrant, const.colourBehaviour.pulsing),
    })
  end

  function TestTransport:testDeliversPlayButtonOnlyOnce()
    reportPlaying(true)
    deliverTransport()
    lu.assertEquals(deliverTransport(), {})
  end

  function TestTransport:testDeliversNothingWhenTransportUnchanged()
    lu.assertEquals(deliverTransport(), {})
  end

  function TestTransport:testRecordButtonTogglesRecording()
    lu.assertTrue(pressRecordButton(127))
    lu.assertEquals(triggeredItem(), items.recordButton.index)
    remote.clearMocks()
    reportRecording(true)
    pressRecordButton(127)
    lu.assertEquals(triggeredItem(), items.recordButton.index)
  end

  function TestTransport:testReleasingRecordButtonDoesNothing()
    lu.assertTrue(pressRecordButton(0))
    lu.assertEquals(#remote.mock "handle_input".calls, 0)
  end

  function TestTransport:testRecordsRecordingState()
    reportRecording(true)
    lu.assertTrue(state.get "transport.recording")
    reportRecording(false)
    lu.assertFalse(state.get "transport.recording")
  end

  function TestTransport:testRecordButtonIsDimAndStaticWhenRecordingIsOff()
    reportRecording(true)
    state.update "transport.recording"
    reportRecording(false)
    lu.assertEquals(deliverTransport(), { makeColourEvent(c.record, colours.red.dim) })
  end

  function TestTransport:testRecordButtonIsBrightAndPulsingWhenRecordingIsOn()
    reportRecording(true)
    lu.assertEquals(deliverTransport(), {
      makeColourEvent(c.record, colours.red.vibrant, const.colourBehaviour.pulsing),
    })
  end

  function TestTransport:testDeliversRecordButtonOnlyOnce()
    reportRecording(true)
    deliverTransport()
    lu.assertEquals(deliverTransport(), {})
  end
end
