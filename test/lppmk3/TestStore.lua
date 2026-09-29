local test = require "test.lib._"
local lu = test.luaUnit
local const = require "src.lppmk3.config.constants"
local ctrl = require "src.lppmk3.config.controls"
local items = require "src.lppmk3.config.items"
local state = require "src.lppmk3.lib.state._"
local colours = require "src.lppmk3.lib.colour.config"
local store = require "src.lppmk3.lib.store._"
local processStore = require "src.lppmk3.remote.processMidi.store"
local processPads = require "src.lppmk3.remote.processMidi.pads"
local setStore = require "src.lppmk3.remote.setState.store"
local deliverStore = require "src.lppmk3.remote.deliverMidi.store"
local defineItemIndices = require "test.lppmk3.defineItemIndices"

TestStore = {}

local white = colours.white.dim
local red = colours.red.vibrant

-- a MIDI event as the host passes it to the codec, from a hex string
local function eventFrom(hexString, port)
  local event = { port = port or const.ports.store, size = 0 }
  for byte in string.gmatch(hexString, "%x%x") do
    event.size = event.size + 1
    event[event.size] = tonumber(byte, 16)
  end
  return event
end

local function receive(hexString)
  return processStore(eventFrom(hexString))
end

-- the hex string of a message of the surface store with the given command
local function message(command, documentName, deviceName, extra)
  local parts = { const.store.sysexHeader, string.format("%02X", command) }
  if documentName then
    table.insert(parts, store.encodeName(documentName))
    table.insert(parts, store.encodeName(deviceName))
  end
  if extra then
    table.insert(parts, extra)
  end
  table.insert(parts, "f7")
  return table.concat(parts, " ")
end

-- the hex string of 64 colours, all white but the first, which is red
local function storedColours()
  local parts = { string.format("%02X", red) }
  for _ = 2, 64 do
    table.insert(parts, string.format("%02X", white))
  end
  return table.concat(parts, " ")
end

-- simulates the host reporting the names of the song and the LaunchEon, with
-- nil for an item that is not mapped
local function reportNames(documentName, deviceName)
  local names = {
    [items.documentName.index] = documentName,
    [items.deviceName.index] = deviceName,
  }
  remote.mock "is_item_enabled":impl(function(index)
    return names[index] ~= nil
  end)
  remote.mock "get_item_text_value":impl(function(index)
    return names[index]
  end)
  setStore({ items.documentName.index, items.deviceName.index })
end

-- simulates pressing a pad with Shift held down, which changes its colour
local function recolourPad(device, value)
  state.set(device .. ".hostValue", value)
  state.set(device .. ".playingValue", value)
  state.shift()
  remote.mock "match_midi":impl(function(midi)
    if midi == "90 xx yy" then
      return { x = (9 - tonumber(string.sub(device, -1))) * 10 + value, y = 127 }
    end
  end)
  processPads({ time_stamp = 0 })
  state.unshift()
end

function TestStore:setUp()
  remote.clearMocks()
  defineItemIndices()
  for _, device in ipairs(ctrl.devices) do
    for value = 1, const.counts.patternValues do
      state.set(device .. ".colour" .. value, white)
    end
  end
  for _, path in ipairs { "documentName", "deviceName", "requestedKey" } do
    state.set("store." .. path, nil)
  end
  state.set("store.awaitingReply", false)
  state.set("store.dirty", false)
  state.set("store.sameSong", false)
end

function TestStore:testEncodesNamesAsNibbles()
  lu.assertEquals(store.encodeName "Ab", "02 04 01 06 02")
end

function TestStore:testEncodesNonAsciiNames()
  lu.assertEquals(store.encodeName "\195\164", "02 0C 03 0A 04")
end

function TestStore:testTruncatesLongNames()
  lu.assertStrContains(store.encodeName(string.rep("x", 200)), "7F ")
end

function TestStore:testParsesColoursMessage()
  local parsed = store.parseMessage(eventFrom(message(3, "My Set", "LaunchEon 1", storedColours())))
  lu.assertEquals(parsed.command, 3)
  lu.assertEquals(parsed.documentName, "My Set")
  lu.assertEquals(parsed.deviceName, "LaunchEon 1")
  lu.assertEquals(#parsed.colours, 64)
  lu.assertEquals(parsed.colours[1], red)
end

function TestStore:testIgnoresOtherSysex()
  lu.assertNil(store.parseMessage(eventFrom "f0 00 20 29 02 0e 0e 01 f7"))
end

function TestStore:testIgnoresTruncatedMessage()
  lu.assertNil(store.parseMessage(eventFrom "f0 7d 52 42 02 05 04 01 f7"))
end

function TestStore:testLeavesEventsFromOtherPortsAlone()
  lu.assertFalse(processStore(eventFrom("f0 7d 52 42 01 f7", const.ports.surface)))
end

function TestStore:testDoesNothingUntilBothNamesAreKnown()
  reportNames("My Set", nil)
  lu.assertEquals(deliverStore(), {})
end

function TestStore:testRequestsColoursOfNewSongAndLaunchEon()
  reportNames("My Set", "LaunchEon 1")
  lu.assertEquals(deliverStore(), { store.makeRequestEvent("My Set", "LaunchEon 1") })
  lu.assertEquals(deliverStore(), {})
end

function TestStore:testShowsStoredColours()
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  lu.assertTrue(receive(message(3, "My Set", "LaunchEon 1", storedColours())))
  lu.assertEquals(state.get "device1.colour1", red)
  lu.assertEquals(state.get "device8.colour8", white)
end

function TestStore:testIgnoresColoursOfAnotherSong()
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  receive(message(3, "Other Set", "LaunchEon 1", storedColours()))
  lu.assertEquals(state.get "device1.colour1", white)
end

function TestStore:testIgnoresColoursNotAskedFor()
  reportNames("My Set", "LaunchEon 1")
  receive(message(3, "My Set", "LaunchEon 1", storedColours()))
  lu.assertEquals(state.get "device1.colour1", white)
end

function TestStore:testStoresCurrentColoursWhenStoreHasNone()
  state.set("device1.colour1", red)
  reportNames("My Set v2", "LaunchEon 1")
  deliverStore()
  receive(message(4, "My Set v2", "LaunchEon 1"))
  lu.assertEquals(deliverStore(), {
    store.makeColoursEvent("My Set v2", "LaunchEon 1", store.colours.get()),
  })
  lu.assertEquals(state.get "device1.colour1", red)
end

function TestStore:testRequestsAgainWhenSongChanges()
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  reportNames("Other Set", "LaunchEon 1")
  lu.assertEquals(deliverStore(), { store.makeRequestEvent("Other Set", "LaunchEon 1") })
end

function TestStore:testSendsColoursWhenPerformerChangesOne()
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  recolourPad("device2", 3)
  lu.assertEquals(state.get "device2.colour3", red)
  lu.assertEquals(deliverStore(), {
    store.makeColoursEvent("My Set", "LaunchEon 1", store.colours.get()),
  })
  lu.assertEquals(deliverStore(), {})
end

function TestStore:testIgnoresReplyAfterPerformerChangedColours()
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  recolourPad("device2", 3)
  receive(message(3, "My Set", "LaunchEon 1", storedColours()))
  lu.assertEquals(state.get "device1.colour1", white)
  lu.assertEquals(state.get "device2.colour3", red)
end

function TestStore:testSendsColoursWhenStoreStartsAfterTheyWereSet()
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  state.set("device1.colour1", red)
  receive(message(1))
  lu.assertEquals(deliverStore(), {
    store.makeColoursEvent("My Set", "LaunchEon 1", store.colours.get()),
  })
end

function TestStore:testRequestsColoursWhenStoreStartsBeforeAnyWereSet()
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  receive(message(1))
  lu.assertEquals(deliverStore(), { store.makeRequestEvent("My Set", "LaunchEon 1") })
end

function TestStore:testForgetsLaunchEonWhileItIsNotFocused()
  reportNames("My Set", "LaunchEon 1")
  reportNames("My Set", nil)
  lu.assertNil(state.get "store.deviceName")
end

-- on an IAC bus used in both directions, the codec hears its own messages
function TestStore:testIgnoresItsOwnEchoedRequest()
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  receive(message(2, "My Set", "LaunchEon 1"))
  lu.assertTrue(state.get "store.awaitingReply")
  lu.assertEquals(deliverStore(), {})
end

function TestStore:testIgnoresItsOwnEchoedColours()
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  recolourPad("device2", 3)
  deliverStore()
  receive(message(3, "My Set", "LaunchEon 1", storedColours()))
  lu.assertEquals(state.get "device1.colour1", white)
  lu.assertEquals(state.get "device2.colour3", red)
end

function TestStore:testDoesNothingWhileSongHasNoName()
  reportNames("", "LaunchEon 1")
  lu.assertNil(state.get "store.documentName")
  lu.assertEquals(deliverStore(), {})
  recolourPad("device2", 3)
  lu.assertEquals(deliverStore(), {})
end

function TestStore:testSendsColoursSetBeforeSongWasFirstSaved()
  reportNames("", "LaunchEon 1")
  recolourPad("device2", 3)
  deliverStore()
  reportNames("My Set", "LaunchEon 1")
  lu.assertEquals(deliverStore(), {
    store.makeColoursEvent("My Set", "LaunchEon 1", store.colours.get()),
  })
end

function TestStore:testLaunchEonAddedToSongStartsOutWhite()
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  receive(message(3, "My Set", "LaunchEon 1", storedColours()))
  reportNames("My Set", "LaunchEon 2")
  lu.assertEquals(deliverStore(), { store.makeRequestEvent("My Set", "LaunchEon 2") })
  receive(message(4, "My Set", "LaunchEon 2"))
  lu.assertEquals(state.get "device1.colour1", white)
  lu.assertEquals(deliverStore(), {
    store.makeColoursEvent("My Set", "LaunchEon 2", store.colours.get()),
  })
end

function TestStore:testSongWithSimilarNameIsNotTheSameSong()
  state.set("device1.colour1", red)
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  reportNames("My Set v2", "LaunchEon 1")
  deliverStore()
  receive(message(4, "My Set v2", "LaunchEon 1"))
  lu.assertEquals(state.get "device1.colour1", red)
end

function TestStore:testSwitchingBetweenLaunchEonsShowsTheirStoredColours()
  reportNames("My Set", "LaunchEon 1")
  deliverStore()
  receive(message(3, "My Set", "LaunchEon 1", storedColours()))
  reportNames("My Set", "LaunchEon 2")
  deliverStore()
  receive(message(4, "My Set", "LaunchEon 2"))
  deliverStore()
  reportNames("My Set", "LaunchEon 1")
  lu.assertEquals(deliverStore(), { store.makeRequestEvent("My Set", "LaunchEon 1") })
  receive(message(3, "My Set", "LaunchEon 1", storedColours()))
  lu.assertEquals(state.get "device1.colour1", red)
end
