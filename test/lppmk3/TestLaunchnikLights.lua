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
    makeColourEvent(60, colours.white.dim),
    makeColourEvent(50, colours.white.dim),
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
-- picking, yellow in clip editing, orange in fill-in editing, blue in landing
-- editing, red in clear mode, and the back button the light of Launchnik's
-- back button: vibrant white in clip picking and clear mode, vibrant green in
-- clip editing, vibrant yellow in fill-in editing, vibrant orange in landing
-- editing, dark in launch mode; the clear button, on control change 60, is
-- dim white in launch mode, vibrant white in clear mode and dark in setup mode
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
  -- in fill-in editing the logo is orange, the back button yellow
  report { setup = 76 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.orange.vibrant),
    makeColourEvent(91, colours.yellow.vibrant),
  })
  -- in landing editing the logo is blue, the back button orange
  report { setup = 140 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.blue.vibrant),
    makeColourEvent(91, colours.orange.vibrant),
  })
  -- in intro editing the logo is pink, the back button blue
  report { setup = 204 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.pink.vibrant),
    makeColourEvent(91, colours.blue.vibrant),
  })
  -- in outro editing the logo is turquoise, the back button pink
  report { setup = 268 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.turquoise.vibrant),
    makeColourEvent(91, colours.pink.vibrant),
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
    makeColourEvent(60, colours.white.dim),
    makeColourEvent(50, colours.white.dim),
  })
  -- in clear mode the logo and the clear button are red, the back button
  -- vibrant white and the duplicate button dark
  report { setup = 322 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.red.vibrant),
    makeColourEvent(91, colours.white.bright),
    makeColourEvent(60, colours.red.vibrant),
    makeColourEvent(50, colours.off),
  })
  report { setup = 0 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.white.bright),
    makeColourEvent(91, colours.off),
    makeColourEvent(60, colours.white.dim),
    makeColourEvent(50, colours.white.dim),
  })
end

-- a Launchnik in launch mode has the setup state the codec starts with, so it
-- is being mapped that lights the logo
function TestLaunchnikLights:testLogoTurnsWhiteWhenLaunchnikIsMapped()
  lu.assertEquals(deliverLaunchnik(), {})
  report { setup = 0 }
  lu.assertEquals(deliverLaunchnik(), mappedFunctionSelect(
    makeColourEvent(99, colours.white.bright),
    makeColourEvent(60, colours.white.dim),
    makeColourEvent(50, colours.white.dim)
  ))
  report { setup = 0 }
  lu.assertEquals(deliverLaunchnik(), {})
  report({ setup = 0 }, false)
  lu.assertEquals(deliverLaunchnik(), unmappedFunctionSelect(
    makeColourEvent(99, colours.off),
    makeColourEvent(60, colours.off),
    makeColourEvent(50, colours.off)
  ))
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
  report { track2clip3fillinonebarpattern = 1 }
  lu.assertTrue(state.fillInOneBarPattern[launchnik.press.buttonIndex(2, 3)])
end

function TestLaunchnikLights:testKeepsIntrosAndOutros()
  local index = launchnik.press.buttonIndex(2, 3)
  report { track2clip3intropresent = 1, track2clip3introcolour = 4, track2clip3introonebarpattern = 1, track2clip3introbpattern = 5 }
  lu.assertTrue(state.introPresent[index])
  lu.assertEquals(state.introColours[index], 4)
  lu.assertTrue(state.introOneBarPattern[index])
  lu.assertEquals(state.introPatterns[index][2], 5)
  report { track2clip3outropresent = 1, track2clip3outrocolour = 6, track2clip3outroctransition = 3, track2clip3outrodunipolar = 2 }
  lu.assertTrue(state.outroPresent[index])
  lu.assertEquals(state.outroColours[index], 6)
  lu.assertEquals(state.outroTransitions[index][3], 3)
  lu.assertEquals(state.outroUnipolar[index][4], 2)
  local button = state.button(index)
  lu.assertEquals(button.intro.colour, 4)
  lu.assertEquals(button.outro.transitions[3], 3)
  report { track2clip3intropresent = 0 }
  lu.assertFalse(state.introPresent[index])
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

-- the fill-in button's light is 1 (dim white) or 8 (vibrant orange) and
-- shows on control change 30; the forward button's is 0 (unlit), 8 (vibrant
-- orange) or 29 (vibrant blue) and shows on control change 92
function TestLaunchnikLights:testFillInAndForwardButtonsShowTheirLights()
  report { setup = 0, fillinlight = 1, forwardlight = 0 }
  lu.assertEquals(deliverLaunchnik(), mappedFunctionSelect(
    makeColourEvent(99, colours.white.bright),
    makeColourEvent(60, colours.white.dim),
    makeColourEvent(50, colours.white.dim),
    makeColourEvent(30, colours.white.dim)
  ))
  report { fillinlight = 8 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(30, colours.orange.vibrant) })
  lu.assertEquals(deliverLaunchnik(), {})
  report { forwardlight = 8 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(92, colours.orange.vibrant) })
  report { forwardlight = 29 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(92, colours.blue.vibrant) })
  report { forwardlight = 0, fillinlight = 1 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(30, colours.white.dim),
    makeColourEvent(92, colours.off),
  })
end

function TestLaunchnikLights:testFillInButtonsGoDarkWhenLaunchnikIsNoLongerMapped()
  report { setup = 0, fillinlight = 8, forwardlight = 8 }
  deliverLaunchnik()
  report({ setup = 0, fillinlight = 8, forwardlight = 8 }, false)
  lu.assertEquals(deliverLaunchnik(), unmappedFunctionSelect(
    makeColourEvent(99, colours.off),
    makeColourEvent(60, colours.off),
    makeColourEvent(50, colours.off),
    makeColourEvent(30, colours.off),
    makeColourEvent(92, colours.off)
  ))
end

-- in clear mode every launch button with something to clear flashes in its
-- clip's colour, here red (light 6), and every scene button with something
-- to clear flashes red, which shows as dim red plus flashing vibrant red,
-- without pulsing; the clear button is red, the duplicate button dark
function TestLaunchnikLights:testClearModeFlashesRed()
  report { setup = 322, track1clip1light = 6, scene1light = 6 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(81, colours.red.dim),
    makeColourEvent(81, colours.red.vibrant, flashing),
    makeColourEvent(2, colours.white.dim),
    makeColourEvent(3, colours.white.dim),
    makeColourEvent(8, colours.red.vibrant),
    makeColourEvent(0x59, colours.red.dim),
    makeColourEvent(0x59, colours.red.vibrant, flashing),
    makeColourEvent(99, colours.red.vibrant),
    makeColourEvent(91, colours.white.bright),
    makeColourEvent(60, colours.red.vibrant),
  })
end

-- in duplicate mode the logo and the duplicate button are fuchsia, the back
-- button vibrant white and the clear button dark; the button to the left of
-- the fourth row of pads shows the duplicate button on control change 50
function TestLaunchnikLights:testDuplicateModeWearsFuchsia()
  report { setup = 0 }
  deliverLaunchnik()
  report { setup = 323 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.fuchsia.vibrant),
    makeColourEvent(91, colours.white.bright),
    makeColourEvent(60, colours.off),
    makeColourEvent(50, colours.fuchsia.vibrant),
  })
  -- destination picking looks the same
  report { setup = 330 }
  lu.assertEquals(deliverLaunchnik(), {})
  report { setup = 393 }
  lu.assertEquals(deliverLaunchnik(), {})
  report { setup = 0 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(99, colours.white.bright),
    makeColourEvent(91, colours.off),
    makeColourEvent(60, colours.white.dim),
    makeColourEvent(50, colours.white.dim),
  })
end

-- the host reports the colours, values and transitions of every clip,
-- fill-in and landing, which a duplicate copies
function TestLaunchnikLights:testStateKeepsWhatADuplicateCopies()
  report { track2clip3colour = 9, track2clip3fillincolour = 4, track2clip3landingcolour = 11, track2clip3fillinbpattern = 5, track2clip3landingcunipolar = 2, track2clip3fillindbipolar = 1 }
  local index = launchnik.press.buttonIndex(2, 3)
  lu.assertEquals(state.colours[index], 9)
  lu.assertEquals(state.fillInColours[index], 4)
  lu.assertEquals(state.landingColours[index], 11)
  lu.assertEquals(state.fillInPatterns[index][2], 5)
  lu.assertEquals(state.landingUnipolar[index][3], 2)
  lu.assertEquals(state.fillInBipolar[index][4], 1)
  local button = state.button(index)
  lu.assertEquals(button.clip.colour, 9)
  lu.assertEquals(button.fillIn.patterns[2], 5)
  lu.assertEquals(button.landing.colour, 11)
end
