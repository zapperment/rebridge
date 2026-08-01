return {
  maxLogMessages = 500,
  debugSysexHeader = "f0 00 20 29 02 0a 02",
  repeatSignal = ".",

  -- if "allow" is non-empty, only messages matching one of its entries pass;
  -- "deny" always wins over "allow"
  allow = {
  },

  deny = {
    "lib."
    --"lib.valueLabels"
    --"getConditionalLabel",
    --"getLabel",
    --"deliverMidi"
  },

}
