# Remember pattern colours in a surface store beside Reason

Pattern colours are the performer's own and unknown to the host, so they were
lost whenever Reason was closed. A codec can neither write files nor store
anything in the song: it only reaches the focused device's remotables and the
Reason Document scope, none of which can hold 64 colours, and it can only
exchange MIDI. So a separate service, the surface store, keeps the colours in a
file and talks to the codec by sysex over a dedicated, optional pair of MIDI
ports. The codec asks for the colours whenever the song or the LaunchEon
changes, telling them apart by Reason's `Document Name` and LaunchEon's
`Device Name`, and sends them on every change, rather than at the start and end
of using the surface, which neither loading another song nor a crash calls.

## Consequences

- Songs, and LaunchEons within a song, are told apart by name alone: songs of
  the same name in different folders share their colours.
- A song that has never been saved has no name, and nothing is stored for it
  until it is first saved, so that new songs do not start out with the
  colours of some earlier unsaved song.
- When the store has no colours for a song and LaunchEon, the pads keep the
  colours they have, which are then stored under the new names. The codec cannot
  tell *Save As* or renaming a LaunchEon from loading another song, and losing
  the colours after *Save As* is the worse surprise than a new song inheriting
  the previous one's.
- Colours are stored as soon as they are set, whether or not the song is saved.
- Without the store running, the codec works as before, with white pads; a store
  started later says hello, and the codec answers with its colours or asks for
  them.

## Considered Options

- Send the colours only when Reason releases the surface: never happens when
  switching songs, nor when Reason crashes.
- Keep the colours in a device parameter of the song itself: the codec cannot
  reach a device that is not focused, and no parameter could hold them all.
- Remember colours globally rather than per song: different songs wire
  different players to LaunchEon, so the same colours would mean different
  things.
