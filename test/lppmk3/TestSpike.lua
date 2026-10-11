local test = require "test.lib._"
local lu = test.luaUnit
local items = require "src.lppmk3.config.items"
local spike = require "src.lppmk3.spike.state"
local processSpike = require "src.lppmk3.spike.processMidi"
local deliverSpike = require "src.lppmk3.spike.deliverMidi"
local colours = require "src.lppmk3.lib.colour.config"
local makeColourEvent = require "src.lppmk3.lib.midi.makeColourEvent"
local defineItemIndices = require "test.lppmk3.defineItemIndices"

-- THROWAWAY: goes when src/lppmk3/spike goes
TestSpike = {}

local layoutReportMidi = "f0 00 20 29 02 0e 00 xx yy 00 f7"

-- simulates the surface sending a note on for the given pad
local function pressPad(pad)
  remote.mock "match_midi":impl(function(midi)
    if midi == "xx yy zz" then
      return { x = 144, y = pad, z = 127 }
    end
    return nil
  end)
  return processSpike({ time_stamp = 0 })
end

-- simulates the surface reporting the given layout
local function reportLayout(layout)
  remote.mock "match_midi":impl(function(midi)
    if midi == layoutReportMidi then
      return { x = layout, y = 0 }
    end
    return nil
  end)
  return processSpike({ time_stamp = 0 })
end

local function handledInput()
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1)
  return calls[1][1]
end

function TestSpike:setUp()
  remote.clearMocks()
  defineItemIndices()
  spike.enabled = true
  spike.present = 0
  spike.colour = 0
  spike.setup = 0
  spike.light = 0
  spike.lightChanged = false
end

function TestSpike:tearDown()
  spike.enabled = false
end

function TestSpike:testFirstPadSwitchesClipOn()
  lu.assertTrue(pressPad(81))
  local input = handledInput()
  lu.assertEquals(input.item, items.spikeClipPresent.index)
  lu.assertEquals(input.value, 1)
end

function TestSpike:testSecondPadWrapsFromLastColourToFirst()
  spike.colour = 13
  lu.assertTrue(pressPad(82))
  local input = handledInput()
  lu.assertEquals(input.item, items.spikeClipColour.index)
  lu.assertEquals(input.value, 0)
end

function TestSpike:testProgrammerLayoutReportSwitchesSetupOn()
  lu.assertTrue(reportLayout(17))
  local input = handledInput()
  lu.assertEquals(input.item, items.spikeSetup.index)
  lu.assertEquals(input.value, 1)
end

function TestSpike:testOtherLayoutReportIsSwallowed()
  lu.assertTrue(reportLayout(18))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestSpike:testLeavesPadsAloneWhileSpikeDeviceIsNotMapped()
  spike.enabled = false
  lu.assertFalse(pressPad(81))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestSpike:testDeliversChangedLightOnce()
  -- frame 4 is vibrant red
  spike.light = 4
  spike.lightChanged = true
  lu.assertEquals(deliverSpike(), { makeColourEvent(81, colours.red.vibrant) })
  lu.assertEquals(deliverSpike(), {})
end
