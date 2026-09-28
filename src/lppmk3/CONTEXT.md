# Launchpad Pro [MK3]

Vocabulary of the Launchpad Pro [MK3] remote codec for Reason: playing the
patterns of a LaunchEon from the pads, the way clips are launched in Ableton
Live's session mode.

## Language

### Surface and host

**Surface**:
The Launchpad Pro [MK3] hardware, used in programmer mode: an 8×8 grid of pads
plus the buttons around it.
_Avoid_: controller, Launchpad (in prose, when the role is meant)

**Host**:
Reason. It owns the LaunchEon's state and reports it; the codec keeps only what
the host cannot know, like the colours of the pads.

**LaunchEon**:
The rack device (by Enlightenspeed) the surface plays; the only device the
codec supports.

### Devices and patterns

**Device**:
One of LaunchEon's eight outputs, each sending one pattern choice to the
players it is wired to; shown on the surface as one row of pads. Named after
LaunchEon's own panel.
_Avoid_: track, lane, channel

**Pattern**:
One of the eight values a device can be set to (1–8), the counterpart of a
clip in Ableton Live. A device plays one pattern at a time, or none.
_Avoid_: clip

**Pattern pad**:
The pad that stands for one pattern of one device: lit brightly in its pattern
colour while that pattern plays, dimly otherwise.

**Pattern colour**:
The colour the performer gives a pattern pad to recognise it on stage. The
host knows nothing about it; it lives on the surface side only.

**Scene**:
One of LaunchEon's 64 stored combinations of patterns across devices. Unlike
an Ableton Live scene, it is not a row of pads.

### Switching patterns in time

**Pattern Timer**:
LaunchEon's setting, labelled "Scenes" on its panel, that delays a device's
change of pattern to the next switch point: Off, ¼, ½, 1, 2 or 4 bars.
_Avoid_: Scene Timer (a different setting, labelled "Master"), clip trigger
quantisation

**Switch interval**:
The length the Pattern Timer is set to. Switch points lie on a grid of this
length counted from the start of bar 1, assuming 4/4 throughout.
_Avoid_: loop

**Switch point**:
A line of the switch interval's grid that playback reaches, either by moving
forward across it or by jumping exactly onto it, as at the end of Reason's
loop; that is where every pending pattern starts to play. A jump onto any
other position is not a switch point.
_Avoid_: loop start

**Playing pattern**:
The pattern a device is actually playing, which may differ from the one the
host reports while a switch is pending.

**Pending pattern**:
The pattern a device will switch to at the next switch point, or no pattern
for a pending stop; until then its pattern pad flashes (for a pending stop, the
playing pattern's pad does). While the transport is stopped, nothing is ever
pending: a change takes effect at once.

**Loop**:
Reason's loop between the left and right locators; unrelated to switching
patterns.
