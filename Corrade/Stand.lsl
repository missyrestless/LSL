// Corrade can also be made to stand-up again by using the stand command

default {
  state_entry() {
    llInstantMessage(CORRADE, 
      wasKeyValueEncode(
        [
          "command", "stand",
          "group", GROUP,
          "password", PASSWORD
        ]
      )
    );
  }
}
