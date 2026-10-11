local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lppmk3.config.constants"
local items = require "src.lppmk3.config.items"
local launchnik = require "src.lppmk3.lib.launchnik._"
local processSetupButton = require "src.lppmk3.remote.processMidi.setupButton"
local processSurface = require "src.lppmk3.remote.processMidi.surface"
local defineItemIndices = require "test.lppmk3.defineItemIndices"

TestProcessSetupButton = {}

local layoutReportMidi = "f0 00 20 29 02 0e 00 xx yy 00 f7"
local programmerLayout = 17
local settingsLayout = 18
local state = launchnik.state

-- makes the surface's next message a report of the given layout
local function reportLayout(layout)
  remote.mock "match_midi":impl(function(midi)
    if midi == layoutReportMidi then
      return { x = layout, y = 0 }
    end
    return nil
  end)
end

local function setTime(ms)
  remote.mock "get_time_ms":impl(function()
    return ms
  end)
end

function TestProcessSetupButton:setUp()
  remote.clearMocks()
  defineItemIndices()
  state.reset()
  setTime(100000)
end

function TestProcessSetupButton:tearDown()
  state.reset()
end

function TestProcessSetupButton:testReleasingSetupEntersClipPicking()
  reportLayout(programmerLayout)
  lu.assertTrue(processSetupButton({ time_stamp = 0 }))
  local calls = remote.mock "handle_input".calls
  lu.assertEquals(#calls, 1)
  lu.assertEquals(calls[1][1].item, items.setup.index)
  lu.assertEquals(calls[1][1].value, 1)
end

function TestProcessSetupButton:testReleasingSetupInSetupModeReturnsToLaunchMode()
  state.setup = 17
  reportLayout(programmerLayout)
  processSetupButton({ time_stamp = 0 })
  lu.assertEquals(remote.mock "handle_input".calls[1][1].value, 0)
end

function TestProcessSetupButton:testReportOfAnotherLayoutIsNotAPress()
  reportLayout(settingsLayout)
  lu.assertTrue(processSetupButton({ time_stamp = 0 }))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

-- the surface also reports the programmer layout when the codec switches it on
function TestProcessSetupButton:testReportAnsweringTheCodecsOwnSwitchIsNotAPress()
  state.preparedAt = 100000 - const.setupButtonQuietTime + 1
  reportLayout(programmerLayout)
  lu.assertTrue(processSetupButton({ time_stamp = 0 }))
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end

function TestProcessSetupButton:testReportWellAfterTheCodecsOwnSwitchIsAPress()
  state.preparedAt = 100000 - const.setupButtonQuietTime
  reportLayout(programmerLayout)
  processSetupButton({ time_stamp = 0 })
  lu.assertEquals(#remote.mock "handle_input".calls, 1)
end

function TestProcessSetupButton:testOtherMidiIsLeftAlone()
  remote.mock "match_midi":impl(function()
    return nil
  end)
  lu.assertFalse(processSetupButton({ time_stamp = 0 }))
end

-- the report arrives on the surface's DAW port, not on the MIDI port its pads
-- and buttons use
function TestProcessSetupButton:testReportIsTakenFromTheDawPort()
  reportLayout(programmerLayout)
  lu.assertTrue(processSurface({ time_stamp = 0, port = const.inputPorts.daw }))
  lu.assertEquals(#remote.mock "handle_input".calls, 1)
end

function TestProcessSetupButton:testReportOnTheMidiPortIsNotAPress()
  reportLayout(programmerLayout)
  processSurface({ time_stamp = 0, port = const.ports.surface })
  lu.assertEquals(#remote.mock "handle_input".calls, 0)
end
