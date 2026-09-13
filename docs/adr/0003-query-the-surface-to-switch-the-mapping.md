# Query the surface to get a chance to switch the mapping

Reason only lets a codec call `remote.handle_input` from `remote_process_midi`,
that is, while it handles MIDI from the surface. When a pattern is selected on
the device's own panel, the codec learns about it in `remote_set_state` and
cannot switch the Patterns group there (see ADR 0001 and 0002). So whenever the
group in force is out of step with the selector parameter, the delivery sends
the Launch Control XL3 a query for its surface mode (`b7 1e 00`, a feature
control queried on channel 8); the surface's reply (`b6 1e xx`) comes back
through `remote_process_midi`, where the codec switches the group and consumes
the reply. Every other MIDI event from the surface is used the same way, so if
the surface ever stopped answering, the mapping would still catch up on the next
touch of a control — the fallback we would otherwise have had to settle for.

## Considered Options

- Switch the group on the next touch only: the encoders would show and change
  the previous pattern until then.
- Map every pattern to its own codec-side items instead of using groups: no
  switching needed, but roughly triples the items (rejected in ADR 0001).
