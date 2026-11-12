local press = require "src.lppcommon.lib.launchnik.press"

-- The control changes of the surface's round buttons in programmer mode that
-- the codec uses, other than the scene buttons, the play button and the
-- record button, which are the same on the Launchpad Pro. The pads send
-- notes 11 at the bottom left to 88 at the top right, the scene buttons the
-- control change that continues the numbering of the pads in their row.
return {
  shift = 90,
  -- the button with the arrow pointing left, beside Shift
  back = 91,
  -- the button with the arrow pointing right, above the second column of pads
  forward = 92,
  -- the buttons in the left-hand column beside the third, fourth and sixth
  -- rows of pads from the top
  clear = 60,
  duplicate = 50,
  fillIn = 30,
  -- the Setup button sends no control change; releasing it makes the surface
  -- report its layout on the DAW port instead (see
  -- remote/processMidi/setupButton.lua)
  setup = nil,
  -- the Novation logo, which shows the mode colour
  logo = 99,
  -- the function buttons, in the upper of the two rows beneath the grid, send
  -- 101 to 108
  firstFunctionButton = 101,
  -- the function select buttons, in the lower row: mute, solo and stop
  functionSelectButtons = {
    [2] = press.functionMute,
    [3] = press.functionSolo,
    [8] = press.functionStop,
  },
  -- they are buttons of their own, not the function buttons with Shift held
  functionSelectWithShift = false,
}
