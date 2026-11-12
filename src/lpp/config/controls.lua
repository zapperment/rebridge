local press = require "src.lppcommon.lib.launchnik.press"

-- The control changes of the surface's round buttons in programmer layout
-- that the codec uses, other than the scene buttons, the play button (Double,
-- CC 20) and the record button (Record, CC 10), which are the same as on the
-- Launchpad Pro [MK3]. The pads send notes 11 at the bottom left to 88 at the
-- top right, the scene buttons the control change that continues the
-- numbering of the pads in their row.
return {
  -- the top button of the left-hand column
  shift = 80,
  -- the buttons with the arrows pointing left and right, in the top row
  back = 93,
  forward = 94,
  -- the Delete, Duplicate and Quantise buttons in the left-hand column
  clear = 50,
  duplicate = 30,
  fillIn = 40,
  -- the surface's own Setup button sends nothing in programmer layout, so the
  -- Session button in the top row stands for Launchnik's setup button
  setup = 95,
  -- the LED on the front edge of the surface, which shows the mode colour
  logo = 99,
  -- there is only one row of buttons beneath the grid, which send 1 to 8:
  -- they are the function buttons
  firstFunctionButton = 1,
  -- with Shift held, the buttons of that row printed Mute, Solo and Stop Clip
  -- are the function select buttons
  functionSelectButtons = {
    [3] = press.functionMute,
    [4] = press.functionSolo,
    [8] = press.functionStop,
  },
  functionSelectWithShift = true,
}
