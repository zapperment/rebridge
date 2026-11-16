-- In its Session layout the surface sends, and takes for its lights, nearly
-- what the codec knows every Launchpad's pads and buttons by (see
-- src/lpcommon/config/sixteenButtonControls.lua): notes 11 at the bottom
-- left to 88 at the top right for the pads, and 19 to 89 for the scene
-- buttons. It differs from the later Launchpads in two ways: the scene
-- buttons send notes, as the pads do, and the buttons of the top row send
-- control changes 104 to 111, where the codec has them at the places 91 to
-- 98.

local noteOn = 0x90
local controlChange = 0xB0
local firstTopRowButton = 104
local firstTopRowPlace = 91

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
    return noteOn, place
  end
  return nil
end

-- the place of the pad or button that sends the note or control change with
-- the status and number given; nil if none does
function address.placeOf(status, number)
  if status == controlChange then
    if number >= firstTopRowButton and number < firstTopRowButton + 8 then
      return firstTopRowPlace + number - firstTopRowButton
    end
    return nil
  end
  if status ~= noteOn then
    return nil
  end
  local row = math.floor(number / 10)
  local column = number % 10
  if row < 1 or row > 8 or column < 1 then
    return nil
  end
  return number
end

return address
