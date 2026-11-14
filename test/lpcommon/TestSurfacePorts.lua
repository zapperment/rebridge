local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lpcommon.config.constants"
local items = require "src.lpcommon.config.items"
local state = require "src.lpcommon.lib.state._"
local colours = require "src.lpcommon.lib.colour.config"
local makeProcessSurface = require "src.lpcommon.remote.processMidi.surface"
local makeDeliverSurface = require "src.lpcommon.remote.deliverMidi.surface"
local surface = require "src.lpcommon.lib.surface._"
local defineItemIndices = require "test.lpcommon.defineItemIndices"
local receiveMidi = require "test.lpcommon.receiveMidi"

-- defines the test class TestSurfacePorts<suffix> for the device given (see
-- src/lppmk3/device.lua)
return function(device, suffix)
  local TestSurfacePorts = {}
  _G["TestSurfacePorts" .. suffix] = TestSurfacePorts

  local makeColourEvent = device.midi.makeColourEvent
  local processSurface = makeProcessSurface(device)
  local deliverSurface = makeDeliverSurface(device)

  local c = device.controls
  local controlChange = 176

  -- a port that is not the surface's
  local otherPort = const.ports.log

  -- simulates the play button's control change arriving on the given port;
  -- on the Launchpads of the [MK3] generation it is also the colour event
  -- that lights the button while the transport is stopped
  local function receivePlayButtonMidi(port)
    return receiveMidi(processSurface, controlChange, c.play, colours.green.dim, port)
  end

  -- the transport's lights as the surface gets them from the start: the play
  -- button's and, unless it only shows with Shift held, the record button's
  local function transportEvents()
    local events = { makeColourEvent(c.play, colours.green.dim) }
    local onShiftLayer = false
    for _, control in pairs(c.shiftLayer or {}) do
      onShiftLayer = onShiftLayer or control == c.record
    end
    if not onShiftLayer then
      table.insert(events, makeColourEvent(c.record, colours.red.dim))
    end
    return events
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
    state.setShifted(false)
    surface.makeShiftLayer(device).reset()
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
    lu.assertEquals(deliverSurface(const.ports.surface), transportEvents())
  end

  function TestSurfacePorts:testDeliversNothingToOtherPort()
    lu.assertEquals(deliverSurface(otherPort), {})
  end

  function TestSurfacePorts:testOtherPortLeavesTransportToBeDelivered()
    deliverSurface(otherPort)
    lu.assertEquals(deliverSurface(const.ports.surface), transportEvents())
  end
end
