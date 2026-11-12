local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lppcommon.config.constants"
local items = require "src.lppcommon.config.items"
local colours = require "src.lppcommon.lib.colour.config"
local launchnik = require "src.lppcommon.lib.launchnik._"
local makeCodec = require "src.lppcommon.codec"
local makePadsOff = require "src.lppcommon.remote.deliverMidi.padsOff"
local defineItemIndices = require "test.lppcommon.defineItemIndices"

-- defines the test class TestCodec<suffix> for the device given (see
-- src/lppmk3/device.lua)
return function(device, suffix)
  local TestCodec = {}
  _G["TestCodec" .. suffix] = TestCodec

  local codec = makeCodec(device)

  function TestCodec:setUp()
    remote.clearMocks()
    launchnik.state.reset()
  end

  function TestCodec:tearDown()
    launchnik.state.reset()
    -- the items get back the indices the other tests count on
    defineItemIndices()
  end

  function TestCodec:testInitDefinesEveryItemOnce()
    codec.init()
    local calls = remote.mock "define_items".calls
    lu.assertEquals(#calls, 1)
    local defined = calls[1][1]
    local count = 0
    for name, item in pairs(items) do
      count = count + 1
      lu.assertEquals(defined[item.index].name, name)
      lu.assertEquals(defined[item.index].min, item.min)
      lu.assertEquals(defined[item.index].max, item.max)
    end
    lu.assertEquals(#defined, count)
  end

  -- what the device sends to switch the surface over, then every pad and the
  -- buttons around the grid off
  function TestCodec:testPrepareForUseSwitchesTheSurfaceOverAndTurnsThePadsOff()
    local events = codec.prepareForUse()
    local expected = device.prepareForUse()
    for _, event in ipairs(makePadsOff(device)()) do
      table.insert(expected, event)
    end
    lu.assertEquals(events, expected)
  end

  function TestCodec:testDeliversToTheSurfacePortOnly()
    launchnik.state.mapped = true
    local logo = device.midi.makeColourEvent(device.controls.logo, colours.white.bright)
    lu.assertEquals(codec.deliverMidi(1024, const.ports.surface + 2), {})
    local delivered = false
    for _, event in ipairs(codec.deliverMidi(1024, const.ports.surface)) do
      delivered = delivered or event == logo
    end
    lu.assertTrue(delivered)
  end

  function TestCodec:testReleaseFromUseIsTheDevicesOwn()
    lu.assertEquals(codec.releaseFromUse(), device.releaseFromUse())
  end
end
