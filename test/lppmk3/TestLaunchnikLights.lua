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
    makeColourEvent(99, colours.yellow.vibrant),
  })

  report { setup = 0 }
  events = deliverLaunchnik()
  lu.assertItemsEquals(events, {
    makeColourEvent(81, colours.red.vibrant, pulsing),
    makeColourEvent(99, colours.white.bright),
  })
end

function TestLaunchnikLights:testTrackAndSceneButtonsDoNotPulse()
  report { track8stoplight = 2, scene1light = 5 }
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

-- the track buttons are control changes 101 to 108
function TestLaunchnikLights:testStopLightsShowOnTheTrackButtonsInRed()
  report { track1stoplight = 1 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(101, colours.red.dim) })
  report { track8stoplight = 2 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(108, colours.red.vibrant) })
  report { track3stoplight = 3 }
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(103, colours.red.dim),
    makeColourEvent(103, colours.red.vibrant, flashing),
  })
  report { track3stoplight = 0 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(103, colours.off) })
  lu.assertEquals(deliverLaunchnik(), {})
end

function TestLaunchnikLights:testStopLightRangeIsThatOfLaunchniksRemoteItem()
  for track = 1, 8 do
    local item = items["track" .. track .. "stoplight"]
    lu.assertEquals({ item.min, item.max }, { 0, 3 })
  end
end

-- the logo shows Launchnik's mode colour: white in launch mode, green in clip
-- picking, yellow in clip editing
function TestLaunchnikLights:testLogoShowsTheModeColour()
  report { setup = 1 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(99, colours.green.vibrant) })
  report { setup = 12 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(99, colours.yellow.vibrant) })
  -- editing another launch button keeps the colour
  report { setup = 13 }
  lu.assertEquals(deliverLaunchnik(), {})
  report { setup = 0 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(99, colours.white.bright) })
end

-- a Launchnik in launch mode has the setup state the codec starts with, so it
-- is being mapped that lights the logo
function TestLaunchnikLights:testLogoTurnsWhiteWhenLaunchnikIsMapped()
  lu.assertEquals(deliverLaunchnik(), {})
  report { setup = 0 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(99, colours.white.bright) })
  report { setup = 0 }
  lu.assertEquals(deliverLaunchnik(), {})
  report({ setup = 0 }, false)
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(99, colours.off) })
end

-- while no Launchnik is mapped, its items are disabled
function TestLaunchnikLights:testPadsAndLogoGoDarkWhenLaunchnikIsNoLongerMapped()
  report { track1clip1light = 5, track1clip1present = 1, track1stoplight = 2, setup = 1 }
  deliverLaunchnik()
  report({ track1clip1light = 5, track1clip1present = 1, track1stoplight = 2, setup = 1 }, false)
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(81, colours.off),
    makeColourEvent(101, colours.off),
    makeColourEvent(99, colours.off),
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
