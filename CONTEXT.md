# ReBridge

Vocabulary of the Launch Control XL3 remote codec for Reason: what the surface's
controls, the host's parameters and the pieces that tie them together are called.

## Language

### Surface and host

**Surface**:
The Launch Control XL3 hardware: 24 encoders in three rows of eight, 8 faders,
16 buttons in two rows of eight, and the page and transport buttons.
_Avoid_: controller, hardware, LCXL3 (in prose)

**Host**:
Reason. It owns the parameters and reports their values; the codec never keeps
a value of its own.
_Avoid_: DAW, Reason (when the role, not the product, is meant)

**Control**:
One physical element of the surface (an encoder, fader or button).
_Avoid_: item, knob, rotary

**Parameter**:
A remotable value of a device that a control can be mapped to, named exactly as
in the device's Remote Info.
_Avoid_: remotable, remotable item, param (in prose)

**Device type**:
The short name a remote-map scope gives its device (`subtractor`, `legend`, …),
under which all per-device configuration is keyed.

**Remote Info**:
Reason's export of a device's parameters with their ranges and types, kept
under `docs/Remote Mapping Info`. Authoritative for what can be mapped.

### Binding controls to parameters

**Mapping**:
The assignment of one control to one parameter, made in the remote map.

**Plain device**:
A device with a single mapping of the surface; the Combinator, for instance.

**Paged device**:
A device with more parameters than controls, whose mapping is split into pages.

**Page**:
One of the alternative mappings of a paged device, stepped through with the
surface's page buttons.
_Avoid_: variation, group (Reason's terms for the mechanism, not the concept)

**Selecting device**:
A device whose mapping is picked by one of its own parameters rather than by
the page buttons; most players with patterns are selecting devices. A device is
paged or selecting, never both.

**Selection**:
The set of alternative mappings of a selecting device, one per option of its
selector parameter, plus the one in force while no option is selected.
_Avoid_: radio group, variation

**Selector parameter**:
The parameter of a selecting device whose value says which option is selected
(`Pattern Select` on the players). The host owns it: the surface changes it
like any other parameter and follows whatever the host reports.

**Option**:
One value of the selector parameter and the mapping that goes with it; a
Bassline Generator's options are its eight patterns.

**Selection button**:
One of the surface's bottom-row buttons on a selecting device: each stands for
one option, lit brightly while its option is selected and dimly otherwise.
Pressing the lit one deselects, leaving no option selected.
_Avoid_: radio button, pattern button

**Alt mapping**:
A second (or third…) parameter mapped to the same control within one page, of
which only one is on show at a time, chosen by a conditional. Ripley's Delay
Time and Synced Time share one encoder this way.

**Conditional**:
A rule that makes a parameter's label, colour or visibility depend on the
value of another parameter of the same device.

**Cycle parameter**:
A parameter mapped to a button that steps to its next value on every press,
like the stepping buttons on the device's own panel; the codec works out the
next value.

**Momentary parameter**:
A parameter that behaves like a pushbutton on the device's panel, like the
Bassline Generator's Run: the host flips it whenever the button goes down and
reports back only whether the button is down, never the parameter's state, so
the surface shows the press and nothing else.

**Display name**:
The parameter name as shown on the surface: the host's name, shortened for a
device whose names would otherwise be cut off.

**Custom display value**:
A label the codec shows in place of the host's value text, for devices whose
host text is unhelpful (SubTractor reports 0–127 for everything).

**Rack UI following**:
Turning a control makes the device's own panel show the tab that parameter
lives on, by setting the panel's tab-selector parameter.

**Pickup**:
A fader only takes over its parameter once it has been moved past the
parameter's current value, so that switching pages does not jump values.

### Bassline Generator

**Pattern**:
One of the eight independent basslines of a Bassline Generator; every pattern
has its own full set of lane and rhythm parameters. Exactly one pattern is
selected at a time, or none.

**No pattern**:
The Bassline Generator's state with no option selected (`Pattern Select` is
−1): the panel shows "No pattern selected" and no pattern's parameters are
editable, on the panel or on the surface.

**Lane**:
Either of the two note streams of a pattern, OnBeat and OffBeat, each with its
own bank, source, velocity, note length and variator.
_Avoid_: channel, voice, side

**Bank**:
The half (A or B) of the lane's phrase pool the lane's source is taken from.

**Source**:
The phrase, 1–64, a lane plays from its bank.
_Avoid_: preset, phrase number
