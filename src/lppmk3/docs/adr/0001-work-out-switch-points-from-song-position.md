# Work out switch points from the song position

When LaunchEon's Pattern Timer is on, the host reports a device's new pattern
the moment it is selected, while LaunchEon only starts playing it at the next
switch point; no remotable says what a device is actually playing. So the codec
keeps the playing pattern itself and moves it to the host value when the song
position reaches a switch point, when the transport stops or when the timer is
turned off. What counts as a switch point copies LaunchEon's behaviour, found
by trying it out in Reason: playback moving forward across a line of the switch
interval's grid (counted from bar 1), or jumping back exactly onto one; a jump
back to anywhere else is not one, so with a loop shorter than the interval, a
pending pattern never plays.

## Consequences

- The codec assumes 4/4 throughout, as the host does not report the time
  signature. In any other signature, pads stop flashing at the wrong moment,
  although LaunchEon still switches at the right one.
- The codec does not know the playing pattern when a device is made active; it
  takes the host value, which may already be a pending pattern.
- If a future version of LaunchEon changed its switching rule, the pads would
  be out of step with what plays until the codec's rule is changed to match.

## Considered Options

- Trust the host value alone: the pad of the new pattern lights up the moment
  it is pressed, with no sign that it has yet to start playing; for live
  performance, this is what made pending patterns worth showing at all.
- Count bars with Reason Document's `Bar Position` and `Beat Position` text
  outputs: whole-bar intervals would work in any time signature, but ¼ and ½ bar
  would still need the beats per bar, and the text would have to be parsed.
