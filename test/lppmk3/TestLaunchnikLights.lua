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
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(73, colours.white.bright) })
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

function TestLaunchnikLights:testLogoIsGreenWhileSetupModeIsOn()
  report { setup = 1 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(99, colours.green.vibrant) })
  -- moving on to clip editing changes nothing about the logo's colour
  report { setup = 12 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(99, colours.green.vibrant) })
  report { setup = 0 }
  lu.assertEquals(deliverLaunchnik(), { makeColourEvent(99, colours.off) })
end

-- while no Launchnik is mapped, its items are disabled
function TestLaunchnikLights:testPadsAndLogoGoDarkWhenLaunchnikIsNoLongerMapped()
  report { track1clip1light = 5, track1clip1present = 1, setup = 1 }
  deliverLaunchnik()
  report({ track1clip1light = 5, track1clip1present = 1, setup = 1 }, false)
  lu.assertEquals(deliverLaunchnik(), {
    makeColourEvent(81, colours.off),
    makeColourEvent(99, colours.off),
  })
  lu.assertFalse(state.present[0])
  lu.assertEquals(state.setup, 0)
end
