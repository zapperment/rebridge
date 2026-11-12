# Launchpad Pro [MK2]

Vocabulary of the Launchpad Pro [MK2] remote codec for Reason. It drives
Launchnik as the Launchpad Pro [MK3] codec does, from the same code in
`src/lpp`, and uses the words of the [MK3] glossary
(`src/lppmk3/CONTEXT.md`), which this one only adds to: where the [MK2]
lacks a button the [MK3] has, a button with the closest caption stands in.

## Language

**Surface**:
The Launchpad Pro [MK2] hardware, which Novation itself calls just
"Launchpad Pro"; [MK2] tells it apart from the [MK3].
_Avoid_: controller, hardware, LPPMK2 (in prose), Launchpad Pro (alone)

**Programmer layout**:
The surface's layout in which every pad and round button sends its own note or
control change and lights only when told to. The codec switches the surface
to it, in standalone mode, and lights it by SysEx message only, since in this
layout the surface takes flashing and pulsing colours no other way.
_Avoid_: programmer mode (that is the [MK3]'s word)

**Function button**:
One of the eight buttons in the only row beneath the grid (CC 1 to 8), as on
the [MK3].

**Function select button**:
The function button printed Mute (CC 3), Solo (CC 4) or Stop Clip (CC 8)
while Shift is held. While Shift is held, the row shows the function select
buttons' lights, the other five buttons of the row dark, instead of the
function buttons' lights.
_Avoid_: mode button

**Setup button**:
The Session button in the top row (CC 95). The surface's own Setup button
sends nothing in programmer layout. It acts when it is let go, and has no
light.
_Avoid_: settings button, Session button (in prose about Launchnik)

**Logo**:
The LED on the front edge of the surface (LED 99), which shows Launchnik's
mode colour as the [MK3]'s Novation logo does.
_Avoid_: side LED

**Back button**, **Forward button**:
The buttons with the arrows pointing left (CC 93) and right (CC 94) in the top
row.

**Clear button**, **Duplicate button**, **Fill-in button**:
The buttons printed Delete (CC 50), Duplicate (CC 30) and Quantise (CC 40) in
the left-hand column.

**Play button**, **Record button**:
The buttons printed Double (CC 20) and Record (CC 10) in the left-hand column,
which start and stop Reason's transport and switch its recording on and off.
