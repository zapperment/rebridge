return {
  -- the number of encoders, faders and buttons on the remote surface
  counts = {
    encoders = 24,
    faders = 8,
    buttons = 16,
    pageSelects = 11,
  },
  pickupTolerance = 10,
  maxLogMessages = 500,
  sysexHeader = "f0 00 20 29 02 15",
  debugSysexHeader = "f0 00 20 29 02 0a 02",
  fader = {
    unknown = 0,
    tooLow = 1,
    inSync = 2,
    tooHigh = 3,
    unassigned = 4
  },
  interpolation = {
    linear = 0,
    bipolar = 1,
    reciprocal = 2
  }
}
