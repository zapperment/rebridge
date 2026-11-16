# Launchpad MK2

Vocabulary of the Launchpad MK2 remote codec for Reason. It drives Launchnik
as the Launchpad Mini [MK3] codec does, with the same controls
(`src/lpcommon/config/sixteenButtonControls.lua`) under other captions, and
uses the words of the Pro [MK3] glossary (`src/lppmk3/CONTEXT.md`) and of
the Mini [MK3] glossary (`src/lpmmk3/CONTEXT.md`), which this one only adds
to. The surface has the palette of the later Launchpads and the buttons of
the Launchpad Mini (`src/lpm/CONTEXT.md`).

## Language

**Surface**:
The Launchpad MK2 hardware.
_Avoid_: controller, hardware, LPMK2 (in prose), MK2 (on its own)

**Launchpad MK2 for Launchnik**:
The model the codec has in Reason's settings. Reason comes with a codec of
its own for the surface, whose model is "Launchpad MK2"; the other name
lets both be installed side by side.
_Avoid_: Launchpad MK2 (for the model in Reason's settings)

**Session layout**:
The surface's way of numbering its pads that the codec counts on. The
surface has no programmer mode; the codec switches it to this layout.
_Avoid_: programmer mode, session mode

**Place**:
The number the codec knows a pad or button by: 11 at the bottom left of the
grid to 88 at the top right, 19 to 89 for the scene buttons and 91 to 98
for the top row.
_Avoid_: position, index

**Address**:
The MIDI message the surface sends for a pad or button and takes for its
light: the note with the number of the place for the pads and scene
buttons, and control changes 104 to 111 for the top row. The device turns
addresses into places and back (`lib/midi/address.lua`).
_Avoid_: key, note number (for the place)

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
