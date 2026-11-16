local test = require "test.lib._"
local lu = test.luaUnit
local colours = require "src.lpcommon.lib.colour.config"
local items = require "src.lpcommon.config.items"
local launchnik = require "src.lpcommon.lib.launchnik._"
local shared = require "src.lpcommon.config.sixteenButtonControls"
local makeProcessSurface = require "src.lpcommon.remote.processMidi.surface"
local device = require "src.lpm.device"
local makeHarness = require "test.lpcommon.surfaceHarness"
local receiveMidi = require "test.lpcommon.receiveMidi"

-- The Launchpad Mini through the whole codec: what it sends and gets is
-- in its own numbers and colours.
TestDeviceLPM = {}

local c = device.controls
local state = launchnik.state
local press = launchnik.press
local makeColourEvent = device.midi.makeColourEvent
local surface = makeHarness(device)
local processSurface = makeProcessSurface(device)
local noteOn = 144
local controlChange = 176

function TestDeviceLPM:setUp()
  surface.reset()
end

function TestDeviceLPM:tearDown()
  surface.reset()
end

-- the codec resets the surface, which turns every LED off and puts it in
-- the X-Y layout, and has it flash; when done, it resets it again
function TestDeviceLPM:testResetsTheSurfaceAndHasItFlash()
  lu.assertEquals(device.prepareForUse(), { "B0 00 00", "B0 00 28" })
  lu.assertEquals(device.releaseFromUse(), { "B0 00 00" })
end

-- the top row, from the left: Up, Down, Left, Right, Session, User 1,
-- User 2 and Mixer (see src/lpm/CONTEXT.md)
function TestDeviceLPM:testHasTheControlsOfTheOtherSixteenButtonLaunchpads()
  lu.assertEquals({ c.play, c.fillIn, c.back, c.forward, c.setup, c.clear, c.duplicate, c.shift },
    { 91, 92, 93, 94, 95, 96, 97, 98 })
  for name, control in pairs(shared) do
    if name ~= "logo" then
      lu.assertEquals(c[name], control, name)
    end
  end
end

-- it has no logo that lights up
function TestDeviceLPM:testTheSetupButtonShowsTheModeColour()
  lu.assertEquals(c.logo, c.setup)
  lu.assertNotNil(makeColourEvent(c.logo, colours.white.bright))
end

function TestDeviceLPM:testAPadLaunchesItsClip()
  state.present[press.buttonIndex(3, 5)] = true
  -- the third pad of the fifth row from the top
  lu.assertTrue(receiveMidi(processSurface, noteOn, 4 * 16 + 2, 127))
  lu.assertEquals(surface.handledInputs()[1], { time_stamp = 0, item = items.track3selection.index, value = 5 })
end

-- the scene buttons send notes, as the pads do
function TestDeviceLPM:testASceneButtonSendsANote()
  for track = 1, 8 do
    state.present[press.buttonIndex(track, 2)] = true
  end
  lu.assertTrue(receiveMidi(processSurface, noteOn, 1 * 16 + 8, 127))
  lu.assertEquals(surface.handledInputs()[1], { time_stamp = 0, item = items.track1selection.index, value = 2 })
end

function TestDeviceLPM:testTheTopRowSendsControlChanges()
  -- Down, the fill-in button
  lu.assertTrue(receiveMidi(processSurface, controlChange, 105, 127))
  lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.fillin.index, value = 1 } })
end

-- Session acts when it is let go
function TestDeviceLPM:testSessionIsTheSetupButton()
  lu.assertTrue(receiveMidi(processSurface, controlChange, 108, 127))
  lu.assertEquals(surface.handledInputs(), {})
  lu.assertTrue(receiveMidi(processSurface, controlChange, 108, 0))
  lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.setup.index, value = press.setupClipPicking } })
end

-- with Mixer held, the pads of the bottom row are the function buttons
function TestDeviceLPM:testMixerIsShift()
  state.present[press.buttonIndex(3, 1)] = true
  state["function"] = press.functionMute
  lu.assertTrue(receiveMidi(processSurface, controlChange, 111, 127))
  lu.assertTrue(receiveMidi(processSurface, noteOn, 7 * 16 + 2, 127))
  lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.track3mute.index, value = 1 } })
end

function TestDeviceLPM:testOtherMidiIsLeftAlone()
  -- a control change with the number of a pad, and those the codec sends
  lu.assertFalse(receiveMidi(processSurface, controlChange, 4 * 16 + 2, 127))
  lu.assertFalse(receiveMidi(processSurface, controlChange, 0, 40))
  -- a note with the number of a button of the top row
  lu.assertFalse(receiveMidi(processSurface, noteOn, 105, 127))
  lu.assertEquals(surface.handledInputs(), {})
end

-- the launch button of a playing clip, which pulses on the later
-- Launchpads, flashes between bright and dark; one that flashes on
-- Launchnik's panel flashes between dim and bright
function TestDeviceLPM:testLightsAreInTheSurfacesColours()
  surface.report {
    setup = 0,
    -- red and vibrant
    track1clip1light = 1 * 3 + 1 + 1,
    -- green and flashing
    track2clip1light = 5 * 3 + 2 + 1,
  }
  local events = surface.deliver()
  lu.assertEquals({ events[1], events[2], events[3] }, {
    "90 00 0B",
    "90 01 1C",
    "90 01 30",
  })
  -- the mode colour of launch mode, white, on Session
  lu.assertItemsEquals({ "B0 6C 3F" }, (function()
    local found = {}
    for _, event in ipairs(events) do
      if string.sub(event, 1, 5) == "B0 6C" then
        table.insert(found, event)
      end
    end
    return found
  end)())
end
