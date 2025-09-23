// Using the tell command, Corrade can send the on or off message
// on channel 7331 defined in the Corrage_Interface script
//
// Based on the ZHAO-II API, it is possible to do more programatically
// with the Vista AO, for instance: cycling stands, sits, etc…
// The principle is still the same.

llInstantMessage(CORRADE,
    wasKeyValueEncode(
        [
            "command", "tell",
            "group", wasURLEscape(GROUP),
            "password", wasURLEscape(PASSWORD),
            // or "off" to switch the Vista AO off
            "message", "on",
            "entity", "local",
            "type", "Normal",
            "channel", "7331"
        ]
    )
);
