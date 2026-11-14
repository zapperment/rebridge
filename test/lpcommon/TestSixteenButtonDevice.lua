local test = require "test.lib._"
local lu = test.luaUnit
local press = require "src.lpcommon.lib.launchnik.press"
local surface = require "src.lpcommon.lib.surface._"

-- defines the test class TestSixteenButtonDevice<suffix> for the device
-- given, a Launchpad with sixteen buttons around its pads (see
-- src/lpcommon/sixteenButtonDevice.lua), whose system exclusive messages
-- begin with the header given
return function(device, suffix, sysexHeader)
  local TestDevice = {}
  _G["TestSixteenButtonDevice" .. suffix] = TestDevice

  local c = device.controls

  -- the codec switches the surface to programmer mode, in which the pads and
  -- buttons send what the codec expects, and back to live mode when it is done
  function TestDevice:testSwitchesToProgrammerModeAndBack()
    lu.assertEquals(device.prepareForUse(), { sysexHeader .. " 0e 01 f7" })
    lu.assertEquals(device.releaseFromUse(), { sysexHeader .. " 0e 00 f7" })
  end

  -- it takes colours as the Launchpad Pro [MK3] does
  function TestDevice:testLightsByControlChange()
    lu.assertEquals(device.midi.makeColourEvent(11, 5), "B0 0B 05")
    lu.assertEquals(device.midi.makeColourEvent(99, 3, device.const.colourBehaviour.pulsing), "B2 63 03")
  end

  -- the top row, from the left: Up, Down, Left, Right, Session and three
  -- buttons with another caption on each surface (see its CONTEXT.md)
  function TestDevice:testButtonsOfTheTopRow()
    lu.assertEquals({ c.play, c.fillIn, c.back, c.forward, c.setup, c.clear, c.duplicate, c.shift },
      { 91, 92, 93, 94, 95, 96, 97, 98 })
    lu.assertEquals(c.logo, 99)
  end

  -- with Shift held, the pads of the bottom row are the function buttons, the
  -- lowest three scene buttons the function select buttons for stop, solo and
  -- mute, and Up the record button
  function TestDevice:testTheRestIsOnTheShiftLayer()
    local layer = c.shiftLayer
    for track = 1, 8 do
      lu.assertEquals(layer[10 + track], c.firstFunctionButton + track - 1)
    end
    lu.assertEquals(c.functionSelectButtons[layer[39]], press.functionStop)
    lu.assertEquals(c.functionSelectButtons[layer[29]], press.functionSolo)
    lu.assertEquals(c.functionSelectButtons[layer[19]], press.functionMute)
    lu.assertEquals(layer[91], c.record)
    local count = 0
    for _ in pairs(layer) do
      count = count + 1
    end
    lu.assertEquals(count, 12)
  end

  -- a pad or button of the surface
  local function isOnTheSurface(control)
    return surface.isPad(control) or (control >= 19 and control <= 89 and control % 10 == 9) or (control >= 91 and control <= 99)
  end

  -- every control the codec uses is a different one; those of the Shift layer
  -- have numbers that nothing on the surface has, the others are on the
  -- surface
  function TestDevice:testControlsDoNotOverlap()
    local used = {}
    local function use(control)
      lu.assertNil(used[control], "control " .. control .. " used twice")
      used[control] = true
    end
    for _, name in ipairs({ "shift", "back", "forward", "clear", "duplicate", "fillIn", "setup", "logo", "play" }) do
      lu.assertTrue(isOnTheSurface(c[name]), name)
      use(c[name])
    end
    for row = 1, 8 do
      use(row * 10 + 9)
    end
    local onShiftLayer = { c.record }
    for control = c.firstFunctionButton, c.firstFunctionButton + 7 do
      table.insert(onShiftLayer, control)
    end
    for control in pairs(c.functionSelectButtons) do
      table.insert(onShiftLayer, control)
    end
    for _, control in ipairs(onShiftLayer) do
      lu.assertFalse(isOnTheSurface(control), control)
      lu.assertTrue(control <= 127, control)
      use(control)
    end
    -- and each has its place
    local placed = {}
    for place, control in pairs(c.shiftLayer) do
      lu.assertTrue(isOnTheSurface(place), place)
      placed[control] = true
    end
    for _, control in ipairs(onShiftLayer) do
      lu.assertTrue(placed[control], control)
    end
  end
end
