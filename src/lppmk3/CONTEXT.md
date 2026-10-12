# Launchpad Pro [MK3]

Vocabulary of the Launchpad Pro [MK3] remote codec for Reason. The codec drives
Launchnik, and uses Launchnik's own words for everything that belongs to the
device: track, launch button, stop button, clip, selection, light, launch mode,
setup mode, clip picking, clip editing, scene, interval meter. Those are defined in the glossary of the
Launchnik repository (https://github.com/zapperment/launchnik, `CONTEXT.md`) and
are not repeated here.

## Language

**Surface**:
The Launchpad Pro [MK3] hardware.
_Avoid_: controller, hardware, LPPMK3 (in prose)

**Host**:
Reason. It owns the device's values and reports them; the codec keeps copies
only to decide what a press means.
_Avoid_: DAW

**Pad**:
One of the 64 square pads in the surface's 8x8 grid. It stands for the launch
button in the same row and column of Launchnik, shows that launch button's
light, and a press of it means what a click on that launch button means.
_Avoid_: slot, cell, button (for a pad)

**Track button**:
One of the eight buttons in the upper of the two rows beneath the grid. It
stands for the stop button of the track above it and shows that stop button's
light.
_Avoid_: stop pad, slot 0

**Scene button**:
One of the eight buttons in the column to the right of the grid. It stands for
the scene button of Launchnik beside the same row, shows that scene button's
light, and a press of it means what a click on that scene button means. Read
together, the eight show Launchnik's interval meter.
_Avoid_: scene launch button, side button, arrow button

**Setup button**:
The button at the bottom left of the surface. It stands for the setup button of
Launchnik: releasing it means what a click on that button means. It has no
light; the surface's logo is lit while setup mode is on.
_Avoid_: settings button
