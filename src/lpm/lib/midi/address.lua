-- The surface numbers its pads and buttons in its own way, which the rest of
-- the codec does not know: the codec has every Launchpad's pads at the
-- places 11 at the bottom left to 88 at the top right, the scene buttons at
-- 19 to 89 and the top row at 91 to 98 (see
-- src/lpcommon/config/sixteenButtonControls.lua).
--
-- In its X-Y layout the surface sends, and takes for its lights, the note
-- 16 x row + column for the pads, with row 0 at the top and the scene buttons
-- as column 8, and control changes 104 to 111 for the buttons of the top row.

local noteOn = 0x90
local controlChange = 0xB0
local firstTopRowButton = 104

local address = {}

-- the status and number of the MIDI message of the pad or button at the
-- place given; nothing for a place the surface has nothing at
function address.addressOf(place)
  local row = math.floor(place / 10)
  local column = place % 10
  if row == 9 and column >= 1 and column <= 8 then
    return controlChange, firstTopRowButton + column - 1
  end
  if row >= 1 and row <= 8 and column >= 1 and column <= 9 then
    return noteOn, 16 * (8 - row) + column - 1
  end
  return nil
end

-- the place of the pad or button that sends the note or control change with
-- the status and number given; nil if none does
function address.placeOf(status, number)
  if status == controlChange then
    if number >= firstTopRowButton and number < firstTopRowButton + 8 then
      return 91 + number - firstTopRowButton
    end
    return nil
  end
  if status ~= noteOn then
    return nil
  end
  local row = math.floor(number / 16)
  local column = number % 16
  if row > 7 or column > 8 then
    return nil
  end
  return (8 - row) * 10 + column + 1
end

return address
