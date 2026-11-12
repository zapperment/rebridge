# Context Map

## Contexts

- [Launch Control XL3](./src/lcxl3/CONTEXT.md): maps the surface's encoders,
  faders and buttons to the parameters of many Reason devices, page by page
- [Launchpad Pro [MK3]](./src/lppmk3/CONTEXT.md): makes the surface's pads and
  buttons stand for the launch, stop, scene, setup and back buttons of the Launchnik
  rack extension
- [Launchpad Pro [MK2]](./src/lppmk2/CONTEXT.md): does the same with the
  Launchpad Pro that came before the [MK3], using the [MK3]'s vocabulary

## Relationships

- **Launch Control XL3 ↔ Launchpad Pro [MK2] and [MK3]**: independent codecs
  that share only generic library code.
- **Launchpad Pro [MK2] ↔ Launchpad Pro [MK3]**: one codec, in `src/lpp`, made
  for either surface from what sets it apart (`src/lppmk2/device.lua`,
  `src/lppmk3/device.lua`): its control changes, how it lights them and how
  it is switched to and from the layout the codec uses.
- **Launchpad Pro [MK2] and [MK3] → Launchnik**: the codec borrows Launchnik's vocabulary
  and follows its Remote items; Launchnik's glossary and decision records live
  in its own repository (https://github.com/zapperment/launchnik).
- Decisions under `docs/adr` belong to the Launch Control XL3 context.
