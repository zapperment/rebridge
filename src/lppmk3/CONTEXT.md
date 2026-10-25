# Launchpad Pro [MK3]

Vocabulary of the Launchpad Pro [MK3] remote codec for Reason. The codec drives
Launchnik, and uses Launchnik's own words for everything that belongs to the
device: track, launch button, function, function button, stop, mute, solo, clip, selection, light, launch mode,
setup mode, clip picking, clip editing, fill-in, fill-in editing, landing, landing editing,
intro, intro editing, outro, outro editing,
one-bar pattern, relaunch, forward button, clear mode, duplicate mode, source,
destination, source picking, destination picking, scene,
interval meter, length (of the switch interval), immediate, CV output, CV mode,
pattern, unipolar value, bipolar value, transition. Those are defined in the glossary of the
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

**Function button**:
One of the eight buttons in the upper of the two rows beneath the grid. It
stands for the function button of the track above it, shows that function
button's light (red for stop, yellow for mute, blue for solo) and a press of it
means what a click on that function button means in the current function.
_Avoid_: track button, stop pad, slot 0

**Function select button**:
One of the buttons in the lower of the two rows beneath the grid (CC 2 for
mute, CC 3 for solo, CC 8 for stop). It stands for the function select button
of Launchnik with the same caption: vibrant in the function's colour while
that function is chosen, dim white otherwise. The other five buttons of the
row do nothing and are off.
_Avoid_: mode button

**Scene button**:
One of the eight buttons in the column to the right of the grid. It stands for
the scene button of Launchnik beside the same row, shows that scene button's
light, and a press of it means what a click on that scene button means:
launching its scene in launch mode, choosing a length in clip picking. Read
together, the eight show Launchnik's interval meter.
_Avoid_: scene launch button, side button, arrow button

**Setup button**:
The button at the bottom left of the surface. It stands for the setup button of
Launchnik: releasing it means what a click on that button means. It has no
light; the surface's logo shows Launchnik's mode colour instead: white in
launch mode, green in clip picking, yellow in clip editing, orange in fill-in
editing, blue in landing editing, pink in intro editing, turquoise in outro
editing, red in clear mode, fuchsia in duplicate mode.
_Avoid_: settings button

**Back button**:
The button with the arrow pointing left, beside Shift at the top left of the
surface. It stands for the back button of Launchnik: pressing it means what a
click on that button means, and it shows the same light: off in launch mode,
vibrant white in clip picking, clear mode and duplicate mode, vibrant green in
clip editing,
vibrant yellow in fill-in editing, vibrant orange in landing editing, vibrant
blue in intro editing, vibrant pink in outro editing. Like Launchnik's, it
acts when it is let go; holding it down for 200 milliseconds or more goes straight
back to clip picking from fill-in, landing, intro and outro editing.
_Avoid_: left arrow, arrow button, long press

**Forward button**:
The button in the top row above the second column of pads. It stands for the
forward button of Launchnik: pressing it means what a click on that button
means, and it shows the same light: vibrant orange in clip editing, vibrant
blue in fill-in editing, vibrant pink in landing editing and vibrant turquoise
in intro editing of a launch button that holds a clip, off otherwise. Like
the back button, it acts when it is let go.
_Avoid_: right arrow, set fill-in button, fill-in setup button

**Fill-in button**:
The button in the left-hand column beside the sixth row of pads from the top.
It stands for the fill-in button of Launchnik, which is held down for exactly
as long as this button is, and shows the same light: dim white, or vibrant
orange while a fill-in plays.
_Avoid_: fill button, side button

**Clear button**:
The button in the left-hand column beside the third row of pads from the top
(CC 60). It stands for the clear button of Launchnik: pressing it means what a
click on that button means, and it shows the same light: dim white in launch
mode, vibrant red in clear mode, off in setup mode and duplicate mode.
_Avoid_: delete button, side button

**Duplicate button**:
The button in the left-hand column beside the fourth row of pads from the top
(CC 50). It stands for the duplicate button of Launchnik: pressing it means
what a click on that button means, and it shows the same light: dim white in
launch mode, vibrant fuchsia in duplicate mode, off in setup mode and clear
mode.
_Avoid_: copy button, side button
