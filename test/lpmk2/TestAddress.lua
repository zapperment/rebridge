local test = require "test.lib._"
local lu = test.luaUnit
local address = require "src.lpmk2.lib.midi.address"

-- In its Session layout the Launchpad MK2 sends notes with the numbers of
-- their places for its pads and scene buttons, and control changes 104 to
-- 111 for its top row, which the codec knows by the places 91 to 98.
TestAddressLPMK2 = {}

local noteOn = 144
local controlChange = 176

function TestAddressLPMK2:testThePadsSendTheNotesOfTheirPlaces()
  lu.assertEquals({ address.addressOf(11) }, { noteOn, 11 })
  lu.assertEquals({ address.addressOf(18) }, { noteOn, 18 })
  lu.assertEquals({ address.addressOf(45) }, { noteOn, 45 })
  lu.assertEquals({ address.addressOf(88) }, { noteOn, 88 })
end

-- unlike those of the later Launchpads, which send control changes
function TestAddressLPMK2:testTheSceneButtonsSendNotes()
  lu.assertEquals({ address.addressOf(19) }, { noteOn, 19 })
  lu.assertEquals({ address.addressOf(89) }, { noteOn, 89 })
end

function TestAddressLPMK2:testTheTopRowSendsControlChanges104To111()
  lu.assertEquals({ address.addressOf(91) }, { controlChange, 104 })
  lu.assertEquals({ address.addressOf(95) }, { controlChange, 108 })
  lu.assertEquals({ address.addressOf(98) }, { controlChange, 111 })
end

-- the surface has no logo, and nothing beside or beneath its grid
function TestAddressLPMK2:testOtherPlacesHaveNoAddress()
  for _, place in ipairs({ 0, 1, 8, 10, 20, 80, 90, 99, 100, 101, 104, 110, 111 }) do
    lu.assertNil(address.addressOf(place), place)
  end
end

-- every pad and button is where its message says, and no other message
-- comes from anywhere
function TestAddressLPMK2:testEveryAddressHasItsPlaceAndNoOtherHasOne()
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

function TestAddressLPMK2:testOtherMessagesComeFromNowhere()
  -- the numbers the later Launchpads have their top row at
  lu.assertNil(address.placeOf(controlChange, 91))
  lu.assertNil(address.placeOf(controlChange, 98))
  -- a control change with the number of a scene button
  lu.assertNil(address.placeOf(controlChange, 19))
  -- notes of the User layouts, which are sent on other channels
  lu.assertNil(address.placeOf(149, 36))
  -- polyphonic aftertouch
  lu.assertNil(address.placeOf(160, 11))
end
