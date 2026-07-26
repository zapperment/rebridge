-- Bookkeeping for the buttons of the remote surface (Launch Control) that
-- lives outside the diffed state: pressed records the button most recently
-- pressed, consumed by the deliverMidi step to show the parameter name for
-- hardware presses only, never for changes made in the host (Reason). held
-- records which buttons are currently held down, keyed by button name.
return {
  pressed = nil,
  held = {},
}
