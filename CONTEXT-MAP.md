# Context Map

## Contexts

- [Launch Control XL3](./src/lcxl3/CONTEXT.md): maps the surface's encoders,
  faders and buttons to the parameters of many Reason devices, page by page
- [Launchpad Pro [MK3]](./src/lppmk3/CONTEXT.md): makes the surface's pads and
  buttons stand for the launch, stop, scene and setup buttons of the Launchnik
  rack extension

## Relationships

- **Launch Control XL3 ↔ Launchpad Pro [MK3]**: independent codecs that share
  only generic library code.
- **Launchpad Pro [MK3] → Launchnik**: the codec borrows Launchnik's vocabulary
  and follows its Remote items; Launchnik's glossary and decision records live
  in its own repository (https://github.com/zapperment/launchnik).
- Decisions under `docs/adr` belong to the Launch Control XL3 context.
