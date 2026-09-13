# A selection button only sets the selector parameter; the mapping follows the host

On a selecting device the host's selector parameter (`Pattern Select`) and the
active map group must agree. Pressing a selection button could switch the group
straight away and set the parameter alongside, which would re-bind the controls
a round-trip sooner. We instead let the press do nothing but set the parameter,
and switch the group only when the host reports the new value — the same path a
click in the rack or a patch load takes. That keeps the host the single owner
of the selection, as it is of every other value the codec shows, and leaves one
code path instead of two that could disagree. The cost is a few milliseconds
before the encoders re-bind after a press.
