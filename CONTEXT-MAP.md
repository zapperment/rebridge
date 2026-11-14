# Context Map

## Contexts

- [Launch Control XL3](./src/lcxl3/CONTEXT.md): maps the surface's encoders,
  faders and buttons to the parameters of many Reason devices, page by page
- [Launchpad Pro [MK3]](./src/lppmk3/CONTEXT.md): makes the surface's pads and
  buttons stand for the launch, stop, scene, setup and back buttons of the Launchnik
  rack extension
- [Launchpad Pro](./src/lpp/CONTEXT.md): does the same with the original
  Launchpad Pro, which came before the [MK3], using the [MK3]'s vocabulary
- [Launchpad Mini [MK3]](./src/lpmmk3/CONTEXT.md): does the same with the
  Launchpad Mini [MK3], which has so few buttons that some of Launchnik's are
  on its Shift layer
- [Launchpad X](./src/lpx/CONTEXT.md): does the same with the Launchpad X,
  which has the pads and buttons of the Mini [MK3] under other captions

## Relationships

- **Launch Control XL3 ↔ the Launchpads**: independent codecs that share only
  generic library code.
- **Launchpad Pro ↔ Launchpad Pro [MK3] ↔ Launchpad Mini [MK3] ↔ Launchpad
  X**: one codec, in `src/lpcommon`, made for each surface from what sets it
  apart (`device.lua` in `src/lpp`, `src/lppmk3`, `src/lpmmk3` and
  `src/lpx`): its controls, how it lights them and how it is switched to and
  from the layout the codec uses. A surface with fewer buttons than Launchnik
  puts controls on its Shift layer
  (`src/lpcommon/lib/surface/shiftLayer.lua`).
- **Launchpad Mini [MK3] ↔ Launchpad X**: the same device but for its name
  and the header of its system exclusive messages, made by
  `src/lpcommon/sixteenButtonDevice.lua`.
- **The Launchpads → Launchnik**: the codec borrows Launchnik's vocabulary
  and follows its Remote items; Launchnik's glossary and decision records live
  in its own repository (https://github.com/zapperment/launchnik).
- Decisions under `docs/adr` belong to the Launch Control XL3 context.
