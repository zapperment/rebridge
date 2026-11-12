local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lpp.config.constants"
local items = require "src.lpp.config.items"
local state = require "src.lpp.lib.state._"
local colours = require "src.lpp.lib.colour.config"
local makeProcessSurface = require "src.lpp.remote.processMidi.surface"
local makeDeliverSurface = require "src.lpp.remote.deliverMidi.surface"
local defineItemIndices = require "test.lpp.defineItemIndices"

-- defines the test class TestSurfacePorts<suffix> for the device given (see
-- src/lppmk3/device.lua)
return function(device, suffix)
  local TestSurfacePorts = {}
  _G["TestSurfacePorts" .. suffix] = TestSurfacePorts

  local makeColourEvent = device.midi.makeColourEvent
  local processSurface = makeProcessSurface(device)
  local deliverSurface = makeDeliverSurface(device)

  -- the play button sends CC 20 on channel 1, which on the Launchpad Pro
  -- [MK3] is also the colour event that lights it while the transport is
  -- stopped
  local playButtonMidi = "b0 14 xx"

  -- a port that is not the surface's
  local otherPort = const.ports.log

  -- simulates the play button's MIDI arriving on the given port
  local function receivePlayButtonMidi(port)
    remote.mock "match_midi":impl(function(midi)
      if midi == playButtonMidi then
        return { x = colours.green.dim }
      end
      return nil
    end)
    return processSurface({ time_stamp = 0, port = port })
  end

  -- makes the play and record buttons count as changed, as they do when the
  -- codec is loaded
  local function markTransportAsChanged()
    state.set("transport.playing", true)
    state.update "transport.playing"
    state.set("transport.playing", false)
    state.set("transport.recording", true)
    state.update "transport.recording"
    state.set("transport.recording", false)
  end

  function TestSurfacePorts:setUp()
    remote.clearMocks()
    defineItemIndices()
    markTransportAsChanged()
  end

  function TestSurfacePorts:tearDown()
    state.update "transport.playing"
    state.update "transport.recording"
  end

  function TestSurfacePorts:testProcessesMidiFromSurfacePort()
    lu.assertTrue(receivePlayButtonMidi(const.ports.surface))
    local calls = remote.mock "handle_input".calls
    lu.assertEquals(#calls, 1)
    lu.assertEquals(calls[1][1].item, items.playButton.index)
  end

  function TestSurfacePorts:testSwallowsMidiFromOtherPort()
    lu.assertTrue(receivePlayButtonMidi(otherPort))
    lu.assertEquals(#remote.mock "handle_input".calls, 0)
  end

  function TestSurfacePorts:testDeliversTransportToSurfacePort()
    lu.assertEquals(deliverSurface(const.ports.surface), {
      makeColourEvent(20, colours.green.dim),
      makeColourEvent(10, colours.red.dim),
    })
  end

  function TestSurfacePorts:testDeliversNothingToOtherPort()
    lu.assertEquals(deliverSurface(otherPort), {})
  end

  function TestSurfacePorts:testOtherPortLeavesTransportToBeDelivered()
    deliverSurface(otherPort)
    lu.assertEquals(#deliverSurface(const.ports.surface), 2)
  end
end
