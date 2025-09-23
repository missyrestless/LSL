// Corrade can be made to sit on an object found in a 5 meter range
// and accept any animation that the object wants to trigger on Corrade.
// Note that Corrade still uses names to identify assets and that poseball
// has to be the name of an object in Corrade's proximity. The way sitting
// is programmed is that Corrade will scan all the objects on the simulator
// and look for a named primitive. It will then sort the objects from nearest
// to farthest and attempt to sit on the closest primitive that matches the
// given name (in this example, poseball).

default {
  state_entry() {
    llInstantMessage(CORRADE, 
      wasKeyValueEncode(
        [
          "command", "sit",
          "group", GROUP,
          "password", PASSWORD,
          "range", 5,
          "item", "poseball"
        ]
      )
    );
  }
}
