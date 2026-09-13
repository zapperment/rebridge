# Bind controls to the selected pattern with Reason map groups, not codec-side alternates

The Bassline Generator (and other players with `Pattern Select`) has a full set
of parameters per pattern, and the surface's controls must always edit the
pattern the host has selected. We express that as a Reason remote-map group with
one value per pattern and map every control once per value, letting Reason do
the re-binding; the codec only switches the group to follow `Pattern Select`.
The alternative — extending the codec's alt-mapping slots from 4 to 8 per
control and adding a conditional on `Pattern Select` — would roughly triple the
item count polled on every delivery and add a second, codec-side re-binding
mechanism next to the one Reason already provides.

## Consequences

- Reason allows at most ten values per group, so this covers players with up to
  nine patterns plus a "no pattern" value.
- Pattern groups are not pages: they are driven by a host parameter, not by the
  page buttons, and a device uses one or the other.
