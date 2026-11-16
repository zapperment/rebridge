local test = require "test.lib._"
local lu = test.luaUnit
local address = require "src.lpm.lib.midi.address"

-- The Launchpad Mini numbers its pads and buttons in its own way: the
-- note 16 x row + column for the pads and the scene buttons, with row 0 at
-- the top and the scene buttons as column 8, and control changes 104 to 111
-- for the top row. The codec knows them by the places the later Launchpads
-- have them at.
TestAddressLPM = {}

local noteOn = 144
local controlChange = 176

function TestAddressLPM:testThePadsSendNotesFromTheTopLeft()
  lu.assertEquals({ address.addressOf(81) }, { noteOn, 0 })
  lu.assertEquals({ address.addressOf(88) }, { noteOn, 7 })
  lu.assertEquals({ address.addressOf(71) }, { noteOn, 16 })
  lu.assertEquals({ address.addressOf(45) }, { noteOn, 68 })
  lu.assertEquals({ address.addressOf(11) }, { noteOn, 112 })
  lu.assertEquals({ address.addressOf(18) }, { noteOn, 119 })
end

function TestAddressLPM:testTheSceneButtonsSendTheNotesOfColumn8()
  lu.assertEquals({ address.addressOf(89) }, { noteOn, 8 })
  lu.assertEquals({ address.addressOf(19) }, { noteOn, 120 })
end

function TestAddressLPM:testTheTopRowSendsControlChanges()
  lu.assertEquals({ address.addressOf(91) }, { controlChange, 104 })
  lu.assertEquals({ address.addressOf(98) }, { controlChange, 111 })
end

-- the surface has no logo, and nothing beside or beneath its grid
function TestAddressLPM:testOtherPlacesHaveNoAddress()
  for _, place in ipairs({ 0, 1, 8, 10, 20, 80, 90, 99, 100, 101, 110 }) do
    lu.assertNil(address.addressOf(place), place)
  end
end

-- every pad and button is where its message says, and no other message
-- comes from anywhere
function TestAddressLPM:testEveryAddressHasItsPlaceAndNoOtherHasOne()
  local expected = {}
  local count = 0
  for place = 0, 127 do
    local status, number = address.addressOf(place)
    if status then
      lu.assertEquals(address.placeOf(status, number), place)
      expected[status .. ":" .. number] = true
      count = count + 1
    end
  end
  -- 64 pads, 8 scene buttons and the 8 buttons of the top row
  lu.assertEquals(count, 80)
  for _, status in ipairs({ noteOn, controlChange }) do
    for number = 0, 127 do
      if not expected[status .. ":" .. number] then
        lu.assertNil(address.placeOf(status, number), status .. ":" .. number)
      end
    end
  end
end

function TestAddressLPM:testOtherMessagesComeFromNowhere()
  -- columns 9 to 15 of the notes are no buttons
  lu.assertNil(address.placeOf(noteOn, 9))
  lu.assertNil(address.placeOf(noteOn, 127))
  -- the control changes the codec itself sends to set the surface up
  lu.assertNil(address.placeOf(controlChange, 0))
  lu.assertNil(address.placeOf(controlChange, 103))
  lu.assertNil(address.placeOf(controlChange, 112))
  -- polyphonic aftertouch
  lu.assertNil(address.placeOf(160, 0))
end
