# Launchpad Mini

Vocabulary of the Launchpad Mini remote codec for Reason. It drives
Launchnik as the Launchpad Mini [MK3] codec does, with the same controls
(`src/lpcommon/config/sixteenButtonControls.lua`) under other captions, and
uses the words of the Pro [MK3] glossary (`src/lppmk3/CONTEXT.md`) and of
the Mini [MK3] glossary (`src/lpmmk3/CONTEXT.md`), which this one only adds
to. The surface is programmed as the first Launchpad was, which sets it
apart from the later ones in two ways: it numbers its pads and buttons
differently, and its lights have three colours.

## Language

**Surface**:
The Launchpad Mini hardware, the original and the MK2, which differ only in
looks.
_Avoid_: controller, hardware, LPM (in prose), Mini (on its own)

**Place**:
The number the codec knows a pad or button by, which is the one the later
Launchpads send: 11 at the bottom left of the grid to 88 at the top right,
19 to 89 for the scene buttons and 91 to 98 for the top row.
_Avoid_: position, index

**Address**:
The MIDI message the surface sends for a pad or button and takes for its
light: the note 16 x row + column for the pads and scene buttons, with row 0
at the top and the scene buttons as column 8, and control changes 104 to 111
for the top row. The device turns addresses into places and back
(`lib/midi/address.lua`).
_Avoid_: key, note number (for the place)

**X-Y layout**:
The surface's way of numbering its pads that the addresses above belong to,
and the one it starts with. The codec resets the surface to it.

**LED colour**:
What a light of the surface can show: red, green, or both, which gives
amber, each element at one of three brightnesses. Every colour of the codec
becomes the nearest of red, amber and green (`lib/midi/ledColour.lua`).
_Avoid_: palette (which is that of the later Launchpads)

**Flashing**:
The surface showing two copies of its lights in turn. A flashing light is
written to one copy only, so it alternates with what the LED showed; a
pulsing one, which the surface cannot show, alternates with dark.
_Avoid_: blinking, double-buffering (in prose about Launchnik)

**Shift**:
The Mixer button, the last of the top row (place 98).
_Avoid_: Mixer button (in prose about Launchnik), modifier

**Setup button**:
The Session button (place 95). It acts when it is let go. The surface has no
logo that lights up, so its light shows Launchnik's mode colour.
_Avoid_: settings button, Session button (in prose about Launchnik)

**Clear button**, **Duplicate button**:
The buttons printed User 1 (place 96) and User 2 (place 97).

**Back button**, **Forward button**, **Fill-in button**, **Play button**,
**Record button**, **Function button**, **Function select button**:
As on the Mini [MK3]: the arrows of the top row, and pads and scene buttons
on the Shift layer.
