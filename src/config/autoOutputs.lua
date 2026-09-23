return {
  { name = "buttonLed2red",   pattern = "B0 26 xx", x = "value == 1 and 5 or 7",   port = 1 },
  { name = "buttonLed3green", pattern = "B0 27 xx", x = "value == 1 and 21 or 23", port = 1 },
  { name = "buttonLed4blue",  pattern = "B0 28 xx", x = "value == 1 and 45 or 47", port = 1 },
}
