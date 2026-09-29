# Context Map

## Contexts

- [Launch Control XL3](./src/lcxl3/CONTEXT.md): maps the surface's encoders,
  faders and buttons to the parameters of many Reason devices, page by page
- [Launchpad Pro [MK3]](./src/lppmk3/CONTEXT.md): plays LaunchEon from the
  surface's pads in the way of Ableton Live's session mode, for live performance

## Relationships

- **Launch Control XL3 ↔ Launchpad Pro [MK3]**: independent codecs that share
  only generic library code; the same word can mean different things in each
  (a Bassline Generator's "Pattern" is not a LaunchEon "Pattern").
- Decisions under `docs/adr` belong to the Launch Control XL3 context; those of
  the Launchpad Pro [MK3] context are under `src/lppmk3/docs/adr`.
