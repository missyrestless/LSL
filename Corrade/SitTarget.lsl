// Note that Corrade will honour sit targets, such that it will only be able to
// sit on a primitive if that primitive has a sit target set. For example, this
// script will set a sit target for the primitive that it is in and Corrade will
// be able to sit on it. In Second Life avatars can only sit on primitives with
// a sit target set - anything other than that is non-compliant behaviour which
// Corrade does not accept.

default {
  state_entry() {
    llSitTarget(<0, 0, 1>, ZERO_ROTATION);
  }
}
