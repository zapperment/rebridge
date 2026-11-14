local press = require "src.lpcommon.lib.launchnik.press"

-- The controls, in programmer mode, of the Launchpads that have sixteen
-- buttons around their pads: the Launchpad Mini [MK3] and the Launchpad X.
-- The pads send notes 11 at the bottom left to 88 at the top right, the
-- scene buttons to their right the control change that continues the
-- numbering of the pads in their row, and the buttons of the top row control
-- changes 91 to 98. The first five of the top row are the arrows pointing
-- up, down, left and right and the Session button; the last three have
-- another caption on each surface (see the CONTEXT.md of each).
--
-- Launchnik has more buttons than sixteen, so the rest are on the Shift
-- layer (see src/lpcommon/lib/surface/shiftLayer.lua): pads and buttons that
-- are another control while Shift is held. Those controls have numbers that
-- no pad or button of the surface sends.
return {
  -- the last button of the top row
  shift = 98,
  -- the buttons with the arrows pointing left and right
  back = 93,
  forward = 94,
  -- the button with the arrow pointing up; with Shift held it is the record
  -- button
  play = 91,
  record = 110,
  -- the button with the arrow pointing down
  fillIn = 92,
  -- the sixth and seventh buttons of the top row
  clear = 96,
  duplicate = 97,
  -- the Session button; in programmer mode, holding it does not open the
  -- surface's own setup
  setup = 95,
  -- the Novation logo, which shows the mode colour
  logo = 99,
  -- with Shift held, the pads of the bottom row are the function buttons
  firstFunctionButton = 101,
  -- with Shift held, the lowest three scene buttons are the function select
  -- buttons, in the order of the caption of the lowest one: Stop, Solo, Mute
  functionSelectButtons = {
    [111] = press.functionStop,
    [112] = press.functionSolo,
    [113] = press.functionMute,
  },
  shiftLayer = {
    [11] = 101,
    [12] = 102,
    [13] = 103,
    [14] = 104,
    [15] = 105,
    [16] = 106,
    [17] = 107,
    [18] = 108,
    [39] = 111,
    [29] = 112,
    [19] = 113,
    [91] = 110,
  },
}
