local press = require "src.lpcommon.lib.launchnik.press"

-- The control changes of the surface's round buttons in programmer layout
-- that the codec uses, other than the scene buttons, which are the same as on
-- the Launchpad Pro [MK3]. The pads send notes 11 at the bottom left to 88 at
-- the top right, the scene buttons the control change that continues the
-- numbering of the pads in their row.
return {
  -- the top button of the left-hand column
  shift = 80,
  -- with Shift held, a pad shows its clip in Launchnik's big display
  -- instead of launching it
  shiftShows = true,
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
  -- the Double and Record buttons in the left-hand column
  play = 20,
  record = 10,
  -- the surface has no function select buttons of its own: they are the
  -- function buttons printed Mute, Solo and Stop Clip with Shift held, and
  -- have numbers that none of its buttons send
  functionSelectButtons = {
    [113] = press.functionMute,
    [114] = press.functionSolo,
    [118] = press.functionStop,
  },
  -- while Shift is held, the row beneath the grid is the function select
  -- buttons, its other buttons dark (see
  -- src/lpcommon/lib/surface/shiftLayer.lua)
  shiftLayer = {
    [1] = false,
    [2] = false,
    [3] = 113,
    [4] = 114,
    [5] = false,
    [6] = false,
    [7] = false,
    [8] = 118,
  },
}
