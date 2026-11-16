local address = require "src.lpm.lib.midi.address"

return {
  makeColourEvent = require "src.lpm.lib.midi.makeColourEvent",
  addressOf = address.addressOf,
  placeOf = address.placeOf,
}
