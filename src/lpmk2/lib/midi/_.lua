local address = require "src.lpmk2.lib.midi.address"

return {
  makeColourEvent = require "src.lpmk2.lib.midi.makeColourEvent",
  addressOf = address.addressOf,
  placeOf = address.placeOf,
}
