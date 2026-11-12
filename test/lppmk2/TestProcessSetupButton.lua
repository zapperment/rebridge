local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lppmk2.config.constants"
local items = require "src.lpp.config.items"
local launchnik = require "src.lpp.lib.launchnik._"
local makeProcessSurface = require "src.lpp.remote.processMidi.surface"
local device = require "src.lppmk2.device"
local defineItemIndices = require "test.lpp.defineItemIndices"

-- the surface's own Setup button sends nothing in programmer layout; the
-- Session button, control change 95, stands for Launchnik's setup button
TestProcessSetupButtonMK2 = {}

local processSurface = makeProcessSurface(device)
local state = launchnik.state
local controlChange = 176

local function receive(status, data1, data2)
  remote.mock "match_midi":impl(function(midi)
    if midi == "xx yy zz" then
      return { x = status, y = data1, z = data2 }
    end
    return nil
  end)
  return processSurface({ time_stamp = 0, port = const.ports.surface })
end

function TestProcessSetupButtonMK2:setUp()
  remote.clearMocks()
  defineItemIndices()
  state.reset()
end

function TestProcessSetupButtonMK2:tearDown()
  state.reset()
end

-- like the Setup button of the Launchpad Pro [MK3], it acts when it is let go
function TestProcessSetupButtonMK2:testReleasingSetupEntersClipPicking()
  lu.assertTrue(receive(controlChange, 95, 127))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
  lu.assertTrue(receive(controlChange, 95, 0))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1)
  lu.assertEquals(calls[1][1].item, items.setup.index)
  lu.assertEquals(calls[1][1].value, launchnik.press.setupClipPicking)
end

function TestProcessSetupButtonMK2:testReleasingSetupInSetupModeReturnsToLaunchMode()
  state.setup = 17
  receive(controlChange, 95, 127)
  receive(controlChange, 95, 0)
  lu.assertEquals(remote.mock "handle_input".calls[1][1].value, launchnik.press.setupLaunchMode)
end

-- there is no other port it could arrive on
function TestProcessSetupButtonMK2:testMidiFromAnotherPortIsSwallowed()
  remote.mock "match_midi":impl(function()
    return { x = controlChange, y = 95, z = 0 }
  end)
  lu.assertTrue(processSurface({ time_stamp = 0, port = const.ports.log }))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end
