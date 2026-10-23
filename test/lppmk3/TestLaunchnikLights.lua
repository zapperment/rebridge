local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lppmk3.config.constants"
local items = require "src.lppmk3.config.items"
local colours = require "src.lppmk3.lib.colour.config"
local makeColourEvent = require "src.lppmk3.lib.midi.makeColourEvent"
local launchnik = require "src.lppmk3.lib.launchnik._"
local setLaunchnik = require "src.lppmk3.remote.setState.launchnik"
local deliverLaunchnik = require "src.lppmk3.remote.deliverMidi.launchnik"
local defineItemIndices = require "test.lppmk3.defineItemIndices"

-- what the host reports about Launchnik, and what the surface is made to show
TestLaunchnikLights = {}

local state = launchnik.state
local flashing = const.colourBehaviour.flashing
local pulsing = const.colourBehaviour.pulsing

-- simulates the host reporting new values for the named items
local function report(values, isEnabled)
  local byIndex = {}
  local changed = {}
  for name, value in pairs(values) do
    byIndex[items[name].index] = value
    table.insert(changed, items[name].index)
  end
  remote.mock "get_item_state":impl(function(index)
    return { is_enabled = isEnabled ~= false, value = byIndex[index] }
  end)
  setLaunchnik.setState(changed)
end

-- the events with which the function select buttons light up when a
-- Launchnik is mapped, followed by the given ones: dim white for mute and
-- solo, vibrant red for stop, which is the function a song opens with
local function mappedFunctionSelect(...)
  local events = {
    makeColourEvent(2, colours.white.dim),
    makeColourEvent(3, colours.white.dim),
    makeColourEvent(8, colours.red.vibrant),
  }
  for _, event in ipairs({ ... }) do
    table.insert(events, event)
  end
  return events
end

-- the events with which they go dark when it is no longer mapped, followed
-- by the given ones
local function unmappedFunctionSelect(...)
  local events = {
    makeColourEvent(2, colours.off),
    makeColourEvent(3, colours.off),
    makeColourEvent(8, colours.off),
  }
  for _, event in ipairs({ ... }) do
    table.insert(events, event)
  end
  return events
end

function TestLaunchnikLights:setUp()
  remote.clearMocks()
  defineItemIndices()
  setLaunchnik.forgetItemIndices()
  state.reset()
end

function TestLaunchnikLights:tearDown()
  state.reset()
  setLaunchnik.forgetItemIndices()
end

function TestLaunchnikLights:testNothingToDeliverAtFirst()
  lu.assertEquals(deliverLaunchnik(), {})
end

function TestLaunchnikLights:testKeepsWhichLaunchButtonsHoldAClip()
  report { track2clip3present = 1 }
  lu.assertTrue(state.present[launchnik.press.buttonIndex(2, 3)])
  report { track2clip3present = 0 }
  lu.assertFalse(state.present[launchnik.press.buttonIndex(2, 3)])
end

-- light 4 is dim red; track 1 row 1 is the top left pad, 81
function TestLaunchnikLights:testDimLightIsDeliveredOnceAsStaticDimColour()
  report { track1clip1light = 4 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(81, colours.red.dim) })
  lu.assertEquals(deliverLaunchnik(), {})
end

-- light 42 is flashing pink; track 8 row 8 is the bottom right pad, 18
function TestLaunchnikLights:testFlashingLightAlternatesBetweenDimAndVibrant()
  report { track8clip8light = 42 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(18, colours.pink.dim),
    makeColourEvent(18, colours.pink.vibrant, flashing),
  })
end

function TestLaunchnikLights:testVibrantWhiteUsesBrightWhite()
  report { track3clip2light = 2 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(73, colours.white.bright, pulsing) })
end

-- light 5 is vibrant red: in launch mode, the light of a clip that is playing
function TestLaunchnikLights:testPadOfAPlayingClipPulses()
  report { track1clip1light = 5 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(81, colours.red.vibrant, pulsing) })
  lu.assertEquals(deliverLaunchnik(), {})
end

function TestLaunchnikLights:testPadStopsPulsingWhenItsClipStops()
  report { track1clip1light = 5 }
  deliverLaunchnik()
  report { track1clip1light = 4 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(81, colours.red.dim) })
end

-- in setup mode vibrant marks a chosen setting, which stands still
function TestLaunchnikLights:testVibrantPadStandsStillInSetupMode()
  report { setup = 2 }
  deliverLaunchnik()
  report { track1clip1light = 5 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(81, colours.red.vibrant) })
end

-- a pad whose light is vibrant in both modes gets no new light from the host
function TestLaunchnikLights:testVibrantPadIsDeliveredAgainWhenTheModeChanges()
  report { track1clip1light = 5 }
  deliverLaunchnik()

  report { setup = 2 }
  local events = deliverLaunchnik()
  lu.assertItemsEquals(events, {
    makeColourEvent(81, colours.red.vibrant),
    makeColourEvent(2, colours.white.dim),
    makeColourEvent(3, colours.white.dim),
    makeColourEvent(8, colours.red.vibrant),
    makeColourEvent(99, colours.yellow.vibrant),
    makeColourEvent(91, colours.green.vibrant),
  })

  report { setup = 0 }
  events = deliverLaunchnik()
  lu.assertItemsEquals(events, {
    makeColourEvent(81, colours.red.vibrant, pulsing),
    makeColourEvent(99, colours.white.bright),
    makeColourEvent(91, colours.off),
  })
end

function TestLaunchnikLights:testTrackAndSceneButtonsDoNotPulse()
  report { track8functionlight = 2, scene1light = 5 }
  lu.assertItemsEquals(deliverLaunchnik(), {
    makeColourEvent(108, colours.red.vibrant),
    makeColourEvent(0x59, colours.red.vibrant),
  })
end

function TestLaunchnikLights:testEveryLightHasAPaletteEntry()
  for light = 1, 42 do
    report { track1clip1light = light }
    local events = deliverLaunchnik()
    lu.assertTrue(#events >= 1)
    for _, event in ipairs(events) do
      lu.assertNotNil(event)
    end
  end
end

function TestLaunchnikLights:testUnlitTurnsThePadOff()
  report { track1clip1light = 5 }
  deliverLaunchnik()
  report { track1clip1light = 0 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(81, colours.off) })
end

function TestLaunchnikLights:testUnchangedLightIsNotDeliveredAgain()
  report { track1clip1light = 5 }
  deliverLaunchnik()
  report { track1clip1light = 5 }
  lu.assertEquals(deliverLaunchnik(), {})
end

-- the function buttons are control changes 101 to 108; in stop function,
-- which a song opens with, they are red
function TestLaunchnikLights:testFunctionLightsShowInRedInStopFunction()
  report { track1functionlight = 1 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(101, colours.red.dim) })
  report { track8functionlight = 2 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(108, colours.red.vibrant) })
  report { track3functionlight = 3 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(103, colours.red.dim),
    makeColourEvent(103, colours.red.vibrant, flashing),
  })
  report { track3functionlight = 0 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(103, colours.off) })
  lu.assertEquals(deliverLaunchnik(), {})
end

function TestLaunchnikLights:testFunctionItemRangesAreThoseOfLaunchniksRemoteItems()
  lu.assertEquals({ items["function"].min, items["function"].max }, { 0, 2 })
  for track = 1, 8 do
    local item = items["track" .. track .. "functionlight"]
    lu.assertEquals({ item.min, item.max }, { 0, 3 })
    lu.assertEquals({ items["track" .. track .. "mute"].min, items["track" .. track .. "mute"].max }, { 0, 1 })
    lu.assertEquals({ items["track" .. track .. "solo"].min, items["track" .. track .. "solo"].max }, { 0, 1 })
  end
end

-- in mute function the function buttons are yellow, in solo function blue; a
-- change of function delivers every function button again in its new colour
-- (no Launchnik is mapped here, so the function select buttons stay dark)
function TestLaunchnikLights:testFunctionLightsTakeTheColourOfTheFunction()
  report { track1functionlight = 2, track2functionlight = 1, track3functionlight = 0 }
  deliverLaunchnik()
  report { ["function"] = 1 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(101, colours.yellow.vibrant),
    makeColourEvent(102, colours.yellow.dim),
    makeColourEvent(103, colours.off),
    makeColourEvent(104, colours.off),
    makeColourEvent(105, colours.off),
    makeColourEvent(106, colours.off),
    makeColourEvent(107, colours.off),
    makeColourEvent(108, colours.off),
  })
  report { ["function"] = 2, track1functionlight = 1, track2functionlight = 2 }
  local events = deliverLaunchnik()
  lu.assertEquals(events[1], makeColourEvent(101, colours.blue.dim))
  lu.assertEquals(events[2], makeColourEvent(102, colours.blue.vibrant))
  lu.assertEquals(deliverLaunchnik(), {})
end

-- the function select buttons take control changes 2 (mute), 3 (solo) and 8
-- (stop): vibrant in the colour of their function while it is chosen, dim
-- white otherwise
function TestLaunchnikLights:testFunctionSelectButtonsShowTheFunction()
  report { setup = 0 }
  deliverLaunchnik()
  report { ["function"] = 2 }
  local events = deliverLaunchnik()
  lu.assertItemsEquals({ events[#events - 1], events[#events] }, {
    makeColourEvent(3, colours.blue.vibrant),
    makeColourEvent(8, colours.white.dim),
  })
  report { ["function"] = 0 }
  events = deliverLaunchnik()
  lu.assertItemsEquals({ events[#events - 1], events[#events] }, {
    makeColourEvent(3, colours.white.dim),
    makeColourEvent(8, colours.red.vibrant),
  })
end

-- the logo shows Launchnik's mode colour: white in launch mode, green in clip
-- picking, yellow in clip editing, red in fill-in editing, blue in landing
-- editing, and the back button the light of Launchnik's back button: vibrant
-- white in clip picking, vibrant green in clip editing, vibrant yellow in
-- fill-in editing, vibrant red in landing editing, dark in launch mode
function TestLaunchnikLights:testLogoAndBackButtonShowTheSetupState()
  report { setup = 1 }
  lu.assertEquals(deliverLaunchnik(), mappedFunctionSelect(
    makeColourEvent(99, colours.green.vibrant),
    makeColourEvent(91, colours.white.bright)
  ))
  report { setup = 12 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.yellow.vibrant),
    makeColourEvent(91, colours.green.vibrant),
  })
  -- in fill-in editing the logo is red, the back button yellow
  report { setup = 76 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.red.vibrant),
    makeColourEvent(91, colours.yellow.vibrant),
  })
  -- in landing editing the logo is blue, the back button red
  report { setup = 140 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.blue.vibrant),
    makeColourEvent(91, colours.red.vibrant),
  })
  report { setup = 12 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.yellow.vibrant),
    makeColourEvent(91, colours.green.vibrant),
  })
  -- editing another launch button keeps the colours
  report { setup = 13 }
  lu.assertEquals(deliverLaunchnik(), {})
  report { setup = 0 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.white.bright),
    makeColourEvent(91, colours.off),
  })
end

-- a Launchnik in launch mode has the setup state the codec starts with, so it
-- is being mapped that lights the logo
function TestLaunchnikLights:testLogoTurnsWhiteWhenLaunchnikIsMapped()
  lu.assertEquals(deliverLaunchnik(), {})
  report { setup = 0 }
  lu.assertEquals(deliverLaunchnik(), mappedFunctionSelect(makeColourEvent(99, colours.white.bright)))
  report { setup = 0 }
  lu.assertEquals(deliverLaunchnik(), {})
  report({ setup = 0 }, false)
  lu.assertEquals(deliverLaunchnik(), unmappedFunctionSelect(makeColourEvent(99, colours.off)))
end

-- while no Launchnik is mapped, its items are disabled
function TestLaunchnikLights:testPadsLogoAndBackButtonGoDarkWhenLaunchnikIsNoLongerMapped()
  report { track1clip1light = 5, track1clip1present = 1, track1functionlight = 2, setup = 1 }
  deliverLaunchnik()
  report({ track1clip1light = 5, track1clip1present = 1, track1functionlight = 2, setup = 1 }, false)
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(81, colours.off),
    makeColourEvent(101, colours.off),
    makeColourEvent(2, colours.off),
    makeColourEvent(3, colours.off),
    makeColourEvent(8, colours.off),
    makeColourEvent(99, colours.off),
    makeColourEvent(91, colours.off),
  })
  lu.assertFalse(state.present[0])
  lu.assertEquals(state.setup, 0)
end

-- the scene buttons take control changes 89 at the top to 19 at the bottom;
-- light 16 is dim green, 10 dim yellow, 4 dim red
function TestLaunchnikLights:testSceneLightsAreDeliveredOnceToTheSceneButtons()
  report { scene8light = 16 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(0x13, colours.green.dim) })
  lu.assertEquals(deliverLaunchnik(), {})

  report { scene3light = 10 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(0x45, colours.yellow.dim) })

  report { scene1light = 4 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(0x59, colours.red.dim) })
end

function TestLaunchnikLights:testEverySceneButtonHasItsControlChange()
  local controllers = { 0x59, 0x4f, 0x45, 0x3b, 0x31, 0x27, 0x1d, 0x13 }
  for scene, controller in ipairs(controllers) do
    report { ["scene" .. scene .. "light"] = 16 }
    lu.assertEquals(deliverLaunchnik(), { makeColourEvent(controller, colours.green.dim) })
  end
end

function TestLaunchnikLights:testSceneLightGoesOutWhenTheIntervalMeterStartsAgain()
  report { scene1light = 4 }
  deliverLaunchnik()
  report { scene1light = 0 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(0x59, colours.off) })
end

function TestLaunchnikLights:testSceneLightsGoOutWhileNoLaunchnikIsMapped()
  report { scene8light = 16 }
  deliverLaunchnik()
  report({ scene8light = 16 }, false)
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(0x13, colours.off) })
end

-- in clip picking the scene buttons flash: light 3 is flashing white, 18
-- flashing green
function TestLaunchnikLights:testFlashingSceneLightsAreDeliveredAsDimPlusFlashingVibrant()
  report { scene3light = 18 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(0x45, colours.green.dim),
    makeColourEvent(0x45, colours.green.vibrant, flashing),
  })
  report { scene1light = 3 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(0x59, colours.white.dim),
    makeColourEvent(0x59, colours.white.bright, flashing),
  })
end

function TestLaunchnikLights:testKeepsLandings()
  report { track2clip3landingpresent = 1, track2clip3landingctransition = 4 }
  lu.assertTrue(state.landingPresent[launchnik.press.buttonIndex(2, 3)])
  lu.assertEquals(state.landingTransitions[launchnik.press.buttonIndex(2, 3)][3], 4)
  report { track2clip3landingpresent = 0 }
  lu.assertFalse(state.landingPresent[launchnik.press.buttonIndex(2, 3)])
  report { track2clip3landingonebarpattern = 1 }
  lu.assertTrue(state.landingOneBarPattern[launchnik.press.buttonIndex(2, 3)])
end

function TestLaunchnikLights:testKeepsCVSettingsAndFillIns()
  report { track2clip3bpattern = 5, track2clip3fillinpresent = 1 }
  lu.assertEquals(state.patterns[launchnik.press.buttonIndex(2, 3)][2], 5)
  report { track2clip3cunipolar = 4, track2clip3dbipolar = 1, track2clip3etransition = 2, track2clip3fillinftransition = 3, track2cvmodec = 0 }
  lu.assertEquals(state.unipolar[launchnik.press.buttonIndex(2, 3)][3], 4)
  lu.assertEquals(state.bipolar[launchnik.press.buttonIndex(2, 3)][4], 1)
  lu.assertEquals(state.transitions[launchnik.press.buttonIndex(2, 3)][5], 2)
  lu.assertEquals(state.fillInTransitions[launchnik.press.buttonIndex(2, 3)][6], 3)
  lu.assertEquals(state.cvModes[2][3], 0)
  lu.assertTrue(state.fillInPresent[launchnik.press.buttonIndex(2, 3)])
  report { track2clip3fillinpresent = 0 }
  lu.assertFalse(state.fillInPresent[launchnik.press.buttonIndex(2, 3)])
end

-- the fill-in button's light is 1 (dim white) or 5 (vibrant red) and shows on
-- control change 30; the forward button's is 0 (unlit), 5 (vibrant red) or 29
-- (vibrant blue) and shows on control change 92
function TestLaunchnikLights:testFillInAndForwardButtonsShowTheirLights()
  report { setup = 0, fillinlight = 1, forwardlight = 0 }
  lu.assertEquals(deliverLaunchnik(), mappedFunctionSelect(
    makeColourEvent(99, colours.white.bright),
    makeColourEvent(30, colours.white.dim)
  ))
  report { fillinlight = 5 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(30, colours.red.vibrant) })
  lu.assertEquals(deliverLaunchnik(), {})
  report { forwardlight = 5 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(92, colours.red.vibrant) })
  report { forwardlight = 29 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(92, colours.blue.vibrant) })
  report { forwardlight = 0, fillinlight = 1 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(30, colours.white.dim),
    makeColourEvent(92, colours.off),
  })
end

function TestLaunchnikLights:testFillInButtonsGoDarkWhenLaunchnikIsNoLongerMapped()
  report { setup = 0, fillinlight = 5, forwardlight = 5 }
  deliverLaunchnik()
  report({ setup = 0, fillinlight = 5, forwardlight = 5 }, false)
  lu.assertEquals(deliverLaunchnik(), unmappedFunctionSelect(
    makeColourEvent(99, colours.off),
    makeColourEvent(30, colours.off),
    makeColourEvent(92, colours.off)
  ))
end
