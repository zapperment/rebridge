local test = require "test.lib._"
local lu = test.luaUnit
local colours = require "src.lpcommon.lib.colour.config"
local items = require "src.lpcommon.config.items"
local launchnik = require "src.lpcommon.lib.launchnik._"
local shared = require "src.lpcommon.config.sixteenButtonControls"
local makeProcessSurface = require "src.lpcommon.remote.processMidi.surface"
local device = require "src.lpmk2.device"
local makeHarness = require "test.lpcommon.surfaceHarness"
local receiveMidi = require "test.lpcommon.receiveMidi"

-- The Launchpad MK2 through the whole codec: what it sends and gets is
-- in its own numbers.
TestDeviceLPMK2 = {}

local c = device.controls
local state = launchnik.state
local press = launchnik.press
local makeColourEvent = device.midi.makeColourEvent
local surface = makeHarness(device)
local processSurface = makeProcessSurface(device)
local noteOn = 144
local controlChange = 176

function TestDeviceLPMK2:setUp()
  surface.reset()
end

function TestDeviceLPMK2:tearDown()
  surface.reset()
end

-- the surface has no programmer mode: the codec switches it to its Session
-- layout, and turns every LED off when it is done
function TestDeviceLPMK2:testSwitchesToSessionLayoutAndTurnsTheLightsOff()
  lu.assertEquals(device.prepareForUse(), { "f0 00 20 29 02 18 22 00 f7" })
  lu.assertEquals(device.releaseFromUse(), { "f0 00 20 29 02 18 0e 00 f7" })
end

-- the top row, from the left: Up, Down, Left, Right, Session, User 1,
-- User 2 and Mixer (see src/lpmk2/CONTEXT.md)
function TestDeviceLPMK2:testHasTheControlsOfTheOtherSixteenButtonLaunchpads()
  lu.assertEquals({ c.play, c.fillIn, c.back, c.forward, c.setup, c.clear, c.duplicate, c.shift },
    { 91, 92, 93, 94, 95, 96, 97, 98 })
  for name, control in pairs(shared) do
    if name ~= "logo" then
      lu.assertEquals(c[name], control, name)
    end
  end
end

-- it has no logo that lights up
function TestDeviceLPMK2:testTheSetupButtonShowsTheModeColour()
  lu.assertEquals(c.logo, c.setup)
  lu.assertNotNil(makeColourEvent(c.logo, colours.white.bright))
end

function TestDeviceLPMK2:testAPadLaunchesItsClip()
  state.present[press.buttonIndex(3, 5)] = true
  -- the third pad of the fifth row from the top
  lu.assertTrue(receiveMidi(processSurface, noteOn, 43, 127))
  lu.assertEquals(surface.handledInputs()[1], { time_stamp = 0, item = items.track3selection.index, value = 5 })
end

-- the scene buttons send notes, as the pads do
function TestDeviceLPMK2:testASceneButtonSendsANote()
  for track = 1, 8 do
    state.present[press.buttonIndex(track, 2)] = true
  end
  lu.assertTrue(receiveMidi(processSurface, noteOn, 79, 127))
  lu.assertEquals(surface.handledInputs()[1], { time_stamp = 0, item = items.track1selection.index, value = 2 })
end

function TestDeviceLPMK2:testTheTopRowSendsControlChanges()
  -- Down, the fill-in button
  lu.assertTrue(receiveMidi(processSurface, controlChange, 105, 127))
  lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.fillin.index, value = 1 } })
end

-- Session acts when it is let go
function TestDeviceLPMK2:testSessionIsTheSetupButton()
  lu.assertTrue(receiveMidi(processSurface, controlChange, 108, 127))
  lu.assertEquals(surface.handledInputs(), {})
  lu.assertTrue(receiveMidi(processSurface, controlChange, 108, 0))
  lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.setup.index, value = press.setupClipPicking } })
end

-- with Mixer held, the pads of the bottom row are the function buttons
function TestDeviceLPMK2:testMixerIsShift()
  state.present[press.buttonIndex(3, 1)] = true
  state["function"] = press.functionMute
  lu.assertTrue(receiveMidi(processSurface, controlChange, 111, 127))
  lu.assertTrue(receiveMidi(processSurface, noteOn, 13, 127))
  lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.track3mute.index, value = 1 } })
end

function TestDeviceLPMK2:testOtherMidiIsLeftAlone()
  -- control changes with the number of a pad, of a scene button and of a
  -- button of the top row of the later Launchpads
  lu.assertFalse(receiveMidi(processSurface, controlChange, 43, 127))
  lu.assertFalse(receiveMidi(processSurface, controlChange, 79, 127))
  lu.assertFalse(receiveMidi(processSurface, controlChange, 92, 127))
  -- a note with the number of a button of the top row
  lu.assertFalse(receiveMidi(processSurface, noteOn, 105, 127))
  lu.assertEquals(surface.handledInputs(), {})
end

-- the launch button of a playing clip pulses, as on the later Launchpads,
-- and one that flashes on Launchnik's panel flashes
function TestDeviceLPMK2:testLightsAreSentToTheSurfacesAddresses()
  surface.report {
    setup = 0,
    -- red and vibrant
    track1clip1light = 1 * 3 + 1 + 1,
    -- green and flashing
    track2clip1light = 5 * 3 + 2 + 1,
  }
  local events = surface.deliver()
  local byAddress = {}
  for _, event in ipairs(events) do
    local key = string.sub(event, 1, 5)
    byAddress[key] = byAddress[key] or {}
    table.insert(byAddress[key], event)
  end
  -- the first pad of the top row, pulsing
  lu.assertEquals(byAddress["92 51"], { makeColourEvent(81, colours.red.vibrant, device.const.colourBehaviour.pulsing) })
  -- the second, flashing over its dim colour
  lu.assertEquals(#byAddress["90 52"], 1)
  lu.assertEquals(#byAddress["91 52"], 1)
  -- the mode colour of launch mode, white, on Session
  lu.assertEquals(byAddress["B0 6C"], { makeColourEvent(c.setup, colours.white.bright) })
end
