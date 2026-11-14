local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lpcommon.config.constants"
local items = require "src.lpcommon.config.items"
local colours = require "src.lpcommon.lib.colour.config"
local launchnik = require "src.lpcommon.lib.launchnik._"
local makeHarness = require "test.lpcommon.surfaceHarness"

-- Defines the test class TestSixteenButtonShiftLayer<suffix> for the device
-- given, a Launchpad with sixteen buttons around its pads (see
-- src/lpcommon/sixteenButtonDevice.lua): it has only the top row and the
-- scene buttons around its grid. With the last button of its top row
-- (control change 98) held as Shift, the pads of the bottom row (notes 11 to
-- 18) are the function buttons, the lowest three scene buttons (control
-- changes 39, 29 and 19) the function select buttons for stop, solo and
-- mute, and Up (control change 91), the play button, is the record button.
return function(device, suffix)
  local TestShiftLayer = {}
  _G["TestSixteenButtonShiftLayer" .. suffix] = TestShiftLayer

  local state = launchnik.state
  local press = launchnik.press
  local makeColourEvent = device.midi.makeColourEvent
  local surface = makeHarness(device)
  local pulsing = const.colourBehaviour.pulsing
  local flashing = const.colourBehaviour.flashing

  -- the light of a launch button or function button: dim, vibrant or flashing
  -- (0 to 2) in the colour with the given number, counted from 0
  local function light(colour, brightness)
    return colour * 3 + brightness + 1
  end

  function TestShiftLayer:setUp()
    surface.reset()
  end

  function TestShiftLayer:tearDown()
    surface.reset()
  end

  function TestShiftLayer:testWithoutShiftTheBottomRowIsLaunchButtons()
    state.present[press.buttonIndex(3, 8)] = true
    lu.assertTrue(surface.pad(13, 127))
    lu.assertEquals(surface.handledInputs()[1], { time_stamp = 0, item = items.track3selection.index, value = 8 })
  end

  function TestShiftLayer:testWithShiftTheBottomRowIsTheFunctionButtons()
    state.present[press.buttonIndex(3, 1)] = true
    state["function"] = press.functionMute
    surface.holdShift(true)
    lu.assertTrue(surface.pad(13, 127))
    lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.track3mute.index, value = 1 } })
    remote.clearMocks()
    lu.assertTrue(surface.pad(13, 0))
    lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.track3mute.index, value = 0 } })
  end

  -- the pads of the other rows stay launch buttons
  function TestShiftLayer:testWithShiftTheOtherRowsAreLaunchButtons()
    state.present[press.buttonIndex(3, 7)] = true
    surface.holdShift(true)
    surface.pad(23, 127)
    lu.assertEquals(surface.handledInputs()[1], { time_stamp = 0, item = items.track3selection.index, value = 7 })
  end

  -- a function button is let go of as one, even if Shift is let go of first
  function TestShiftLayer:testLettingGoOfShiftDoesNotKeepAFunctionButtonHeld()
    state.present[press.buttonIndex(3, 1)] = true
    state["function"] = press.functionSolo
    surface.holdShift(true)
    surface.pad(13, 127)
    surface.holdShift(false)
    remote.clearMocks()
    lu.assertTrue(surface.pad(13, 0))
    lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.track3solo.index, value = 0 } })
  end

  function TestShiftLayer:testWithShiftTheLowestSceneButtonsChooseTheFunction()
    surface.holdShift(true)
    for control, func in pairs({ [39] = press.functionStop, [29] = press.functionSolo, [19] = press.functionMute }) do
      remote.clearMocks()
      lu.assertTrue(surface.button(control, 127))
      lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items["function"].index, value = func } })
      remote.clearMocks()
      surface.button(control, 0)
      lu.assertEquals(surface.handledInputs(), {})
    end
  end

  -- without Shift they are scene buttons, as the other five always are
  function TestShiftLayer:testSceneButtons()
    for track = 1, 8 do
      state.present[press.buttonIndex(track, 8)] = true
      state.present[press.buttonIndex(track, 4)] = true
    end
    surface.button(19, 127)
    local inputs = surface.handledInputs()
    lu.assertEquals(inputs[1], { time_stamp = 0, item = items.track1selection.index, value = 8 })

    surface.reset()
    for track = 1, 8 do
      state.present[press.buttonIndex(track, 4)] = true
    end
    surface.holdShift(true)
    surface.button(59, 127)
    lu.assertEquals(surface.handledInputs()[1], { time_stamp = 0, item = items.track1selection.index, value = 4 })
  end

  function TestShiftLayer:testUpIsPlayAndWithShiftRecord()
    lu.assertTrue(surface.button(91, 127))
    lu.assertTrue(surface.button(91, 0))
    lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.playButton.index, value = 1 } })
    remote.clearMocks()
    surface.holdShift(true)
    lu.assertTrue(surface.button(91, 127))
    lu.assertTrue(surface.button(91, 0))
    lu.assertEquals(surface.handledInputs(), { { time_stamp = 0, item = items.recordButton.index, value = 1 } })
  end

  -- Up shows whether Reason is playing and, while Shift is held, whether it
  -- is recording
  function TestShiftLayer:testUpShowsPlayingAndWithShiftRecording()
    surface.report { playButton = 1, recordButton = 0 }
    lu.assertEquals(surface.deliver(), { makeColourEvent(91, colours.green.vibrant, pulsing) })
    surface.report { recordButton = 1 }
    lu.assertEquals(surface.deliver(), {})
    surface.holdShift(true)
    local events = surface.deliver()
    lu.assertEquals(events[#events], makeColourEvent(91, colours.red.vibrant, pulsing))
    surface.holdShift(false)
    events = surface.deliver()
    lu.assertEquals(events[#events], makeColourEvent(91, colours.green.vibrant, pulsing))
  end

  -- while Shift is held, the bottom row shows the lights of the function
  -- buttons and the lowest three scene buttons those of the function select
  -- buttons; letting go of Shift brings back what they showed
  function TestShiftLayer:testShiftShowsTheFunctionButtonsAndFunctionSelectButtons()
    surface.report {
      setup = 0,
      track1clip8light = light(1, 1),
      track2clip8light = light(2, 2),
      scene8light = light(0, 0),
      track1functionlight = 2,
      track3functionlight = 3,
    }
    -- the launch buttons, the scene button, and nothing of the Shift layer
    local events = surface.deliver()
    lu.assertEquals({ events[1], events[2], events[3], events[4] }, {
      makeColourEvent(11, colours.red.vibrant, pulsing),
      makeColourEvent(12, colours.orange.dim),
      makeColourEvent(12, colours.orange.vibrant, flashing),
      makeColourEvent(19, colours.white.dim),
    })
    for index = 5, #events do
      lu.assertNotStrContains(events[index], "B0 0D ")
    end

    surface.holdShift(true)
    lu.assertEquals(surface.deliver(), {
      makeColourEvent(11, colours.red.vibrant),
      makeColourEvent(12, colours.off),
      makeColourEvent(13, colours.red.dim),
      makeColourEvent(13, colours.red.vibrant, flashing),
      makeColourEvent(14, colours.off),
      makeColourEvent(15, colours.off),
      makeColourEvent(16, colours.off),
      makeColourEvent(17, colours.off),
      makeColourEvent(18, colours.off),
      -- mute, solo and stop, which is chosen
      makeColourEvent(19, colours.white.dim),
      makeColourEvent(29, colours.white.dim),
      makeColourEvent(39, colours.red.vibrant),
      -- Reason is not recording
      makeColourEvent(91, colours.off),
    })
    lu.assertEquals(surface.deliver(), {})

    -- what changes on the Shift layer shows right away, the launch buttons
    -- beneath it wait
    surface.report { ["function"] = press.functionMute, track1clip8light = light(1, 0) }
    events = surface.deliver()
    lu.assertEquals(events, {
      makeColourEvent(11, colours.yellow.vibrant),
      makeColourEvent(12, colours.off),
      makeColourEvent(13, colours.yellow.dim),
      makeColourEvent(13, colours.yellow.vibrant, flashing),
      makeColourEvent(14, colours.off),
      makeColourEvent(15, colours.off),
      makeColourEvent(16, colours.off),
      makeColourEvent(17, colours.off),
      makeColourEvent(18, colours.off),
      -- stop is no longer chosen, mute is
      makeColourEvent(39, colours.white.dim),
      makeColourEvent(19, colours.yellow.vibrant),
    })

    surface.holdShift(false)
    lu.assertEquals(surface.deliver(), {
      makeColourEvent(11, colours.red.dim),
      makeColourEvent(12, colours.orange.dim),
      makeColourEvent(12, colours.orange.vibrant, flashing),
      makeColourEvent(13, colours.off),
      makeColourEvent(14, colours.off),
      makeColourEvent(15, colours.off),
      makeColourEvent(16, colours.off),
      makeColourEvent(17, colours.off),
      makeColourEvent(18, colours.off),
      makeColourEvent(19, colours.white.dim),
      makeColourEvent(29, colours.off),
      makeColourEvent(39, colours.off),
      makeColourEvent(91, colours.off),
    })
    lu.assertEquals(surface.deliver(), {})
  end
end
