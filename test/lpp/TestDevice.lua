local test = require "test.lib._"
local lu = test.luaUnit
local press = require "src.lpcommon.lib.launchnik.press"
local device = require "src.lpp.device"

TestDeviceLPP = {}

local c = device.controls

-- the codec switches the surface to standalone mode and its programmer
-- layout, in which the pads and round buttons send what the codec expects,
-- and back to the note layout when it is done
function TestDeviceLPP:testSwitchesToTheProgrammerLayoutAndBack()
  lu.assertEquals(device.prepareForUse(), {
    "f0 00 20 29 02 10 21 01 f7",
    "f0 00 20 29 02 10 2c 03 f7",
  })
  lu.assertEquals(device.releaseFromUse(), { "f0 00 20 29 02 10 2c 00 f7" })
end

-- the buttons stand for those of Launchnik with the closest caption printed
-- on them (see src/lpp/CONTEXT.md)
function TestDeviceLPP:testButtonsAreThoseWithTheClosestCaption()
  lu.assertEquals(c.shift, 80)
  lu.assertEquals({ c.back, c.forward }, { 93, 94 })
  lu.assertEquals({ c.clear, c.duplicate, c.fillIn }, { 50, 30, 40 })
  lu.assertEquals(c.setup, 95)
  lu.assertEquals(c.logo, 99)
  lu.assertEquals(c.firstFunctionButton, 1)
  -- Double and Record
  lu.assertEquals({ c.play, c.record }, { 20, 10 })
end

-- with Shift held, the function buttons printed Mute (3), Solo (4) and Stop
-- Clip (8) are the function select buttons, and the rest of the row nothing
function TestDeviceLPP:testFunctionSelectButtonsAreOnTheShiftLayer()
  local functions = {}
  for place = 1, 8 do
    local control = c.shiftLayer[place]
    lu.assertNotNil(control)
    functions[place] = control and c.functionSelectButtons[control]
  end
  lu.assertEquals(functions, { false, false, press.functionMute, press.functionSolo, false, false, false, press.functionStop })
end

-- every control the codec uses is a different one
function TestDeviceLPP:testControlsDoNotOverlap()
  local used = {}
  local function use(control)
    lu.assertNil(used[control], "control " .. control .. " used twice")
    used[control] = true
  end
  for _, name in ipairs({ "shift", "back", "forward", "clear", "duplicate", "fillIn", "setup", "logo", "play", "record" }) do
    use(c[name])
  end
  for control = c.firstFunctionButton, c.firstFunctionButton + 7 do
    use(control)
  end
  for row = 1, 8 do
    use(row * 10 + 9)
  end
  for control in pairs(c.functionSelectButtons) do
    use(control)
  end
end
