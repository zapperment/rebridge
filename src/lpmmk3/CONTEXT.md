# Launchpad Mini [MK3]

Vocabulary of the Launchpad Mini [MK3] remote codec for Reason. It drives
Launchnik as the Launchpad Pro [MK3] codec does, from the same code in
`src/lpcommon`, and uses the words of the Pro [MK3] glossary
(`src/lppmk3/CONTEXT.md`), which this one only adds to: the Mini has only
sixteen buttons, so buttons with another caption stand in, and some of
Launchnik's buttons are on the Shift layer.

## Language

**Surface**:
The Launchpad Mini [MK3] hardware.
_Avoid_: controller, hardware, LPMMK3 (in prose), Mini (on its own)

**Programmer mode**:
The surface's mode in which every pad and button sends its own note or
control change and lights only when told to, as on the Pro [MK3]. The codec
switches the surface to it; while it is on, holding Session does not open
the surface's own setup.

**Shift**:
The User button, the last of the top row (CC 98). It has no light.
_Avoid_: User button (in prose about Launchnik), modifier

**Shift layer**:
The controls that pads and buttons stand for while Shift is held, and whose
lights they show for as long as it is. Letting go of Shift brings back what
they showed before. A pad or button pressed on one layer is let go of on
that layer, whatever Shift does in between.
_Avoid_: shift mode, second layer, page

**Function button**:
One of the pads of the bottom row (notes 11 to 18) on the Shift layer. Without
Shift, those pads are the launch buttons of row 8.

**Function select button**:
One of the lowest three scene buttons on the Shift layer: stop (CC 39), solo
(CC 29) and mute (CC 19), in the order of the caption of the lowest one.
Without Shift, they are scene buttons.
_Avoid_: mode button

**Setup button**:
The Session button (CC 95). It acts when it is let go, and has no light.
_Avoid_: settings button, Session button (in prose about Launchnik)

**Logo**:
The Novation logo (LED 99), which shows Launchnik's mode colour.

**Back button**, **Forward button**:
The buttons with the arrows pointing left (CC 93) and right (CC 94).

**Fill-in button**:
The button with the arrow pointing down (CC 92).

**Clear button**, **Duplicate button**:
The buttons printed Drums (CC 96) and Keys (CC 97).

**Play button**, **Record button**:
The button with the arrow pointing up (CC 91): the play button, and on the
Shift layer the record button. They start and stop Reason's transport and
switch its recording on and off.
