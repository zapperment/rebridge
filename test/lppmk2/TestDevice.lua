local test = require "test.lib._"
local lu = test.luaUnit
local items = require "src.lpp.config.items"
local press = require "src.lpp.lib.launchnik.press"
local device = require "src.lppmk2.device"

TestDeviceMK2 = {}

local c = device.controls

-- the codec switches the surface to standalone mode and its programmer
-- layout, in which the pads and round buttons send what the codec expects,
-- and back to the note layout when it is done
function TestDeviceMK2:testSwitchesToTheProgrammerLayoutAndBack()
  lu.assertEquals(device.prepareForUse(), {
    "f0 00 20 29 02 10 21 01 f7",
    "f0 00 20 29 02 10 2c 03 f7",
  })
  lu.assertEquals(device.releaseFromUse(), { "f0 00 20 29 02 10 2c 00 f7" })
end

-- the buttons stand for those of Launchnik with the closest caption printed
-- on them (see src/lppmk2/CONTEXT.md)
function TestDeviceMK2:testButtonsAreThoseWithTheClosestCaption()
  lu.assertEquals(c.shift, 80)
  lu.assertEquals({ c.back, c.forward }, { 93, 94 })
  lu.assertEquals({ c.clear, c.duplicate, c.fillIn }, { 50, 30, 40 })
  lu.assertEquals(c.setup, 95)
  lu.assertEquals(c.logo, 99)
  lu.assertEquals(c.firstFunctionButton, 1)
  lu.assertEquals(c.functionSelectButtons, { [3] = press.functionMute, [4] = press.functionSolo, [8] = press.functionStop })
  lu.assertTrue(c.functionSelectWithShift)
  -- Double and Record
  lu.assertEquals({ items.playButton.controller, items.recordButton.controller }, { 20, 10 })
end

-- every control the codec uses is a different one
function TestDeviceMK2:testControlsDoNotOverlap()
  local used = {}
  local function use(control)
    lu.assertNil(used[control], "control " .. control .. " used twice")
    used[control] = true
  end
  for _, name in ipairs({ "shift", "back", "forward", "clear", "duplicate", "fillIn", "setup", "logo" }) do
    use(c[name])
  end
  use(items.playButton.controller)
  use(items.recordButton.controller)
  for control = c.firstFunctionButton, c.firstFunctionButton + 7 do
    use(control)
  end
  for row = 1, 8 do
    use(row * 10 + 9)
  end
end
