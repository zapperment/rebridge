local ledX = "value == 1 and 177 or 176"
local ledY = "enabled * (value == 0 and 0 or 5)"

return {
  -- the track buttons show the state of the stop buttons: red, and flashing
  -- while queued; the pads are not here, the codec delivers their lights itself
  { name = "trackButton1led", pattern = "xx 65 yy", x = ledX, y = ledY, port = 1 },
  { name = "trackButton2led", pattern = "xx 66 yy", x = ledX, y = ledY, port = 1 },
  { name = "trackButton3led", pattern = "xx 67 yy", x = ledX, y = ledY, port = 1 },
  { name = "trackButton4led", pattern = "xx 68 yy", x = ledX, y = ledY, port = 1 },
  { name = "trackButton5led", pattern = "xx 69 yy", x = ledX, y = ledY, port = 1 },
  { name = "trackButton6led", pattern = "xx 6a yy", x = ledX, y = ledY, port = 1 },
  { name = "trackButton7led", pattern = "xx 6b yy", x = ledX, y = ledY, port = 1 },
  { name = "trackButton8led", pattern = "xx 6c yy", x = ledX, y = ledY, port = 1 },
}
