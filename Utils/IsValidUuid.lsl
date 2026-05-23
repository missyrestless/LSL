// Check if a string is a valid UUID
// Can simple do: if ((key)uuid_string) but is that sufficient?
// To validate the string format conforms to that of a UUID, check its length and hyphenation:
//
// Implicit check
integer is_uuid(string uuid_str) {
    if ((key)uuid_str) {
        return TRUE;
    } else {
        return FALSE;
    }
}

// Format check
integer is_strict_uuid(string input) {
    if (llStringLength(input) != 36) return FALSE;
    
    // Check hyphen positions (index starts at 0)
    if (llGetSubString(input, 8, 8) != "-" ||
        llGetSubString(input, 13, 13) != "-" ||
        llGetSubString(input, 18, 18) != "-" ||
        llGetSubString(input, 23, 23) != "-") {
        return FALSE;
    }
    
    return (key)input != NULL_KEY;
}
