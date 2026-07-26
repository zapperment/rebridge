-- Records the button most recently pressed on the remote surface (Launch
-- Control). The deliverMidi step consumes this to show the parameter name for
-- hardware presses only, never for changes made in the host (Reason).
return {
  pressed = nil
}
