// JSON_TYPE integers
integer invalid = 1;   // invalid
integer null    = 32;  // null

// Unused but here to document
// integer object  = 2;   // object
// integer array   = 4;   // array
// integer number  = 8;   // number
// integer str     = 16;  // string
// integer true    = 64;  // true
// integer false   = 128; // false

// map the json type to a useful bitmask
integer jsonType(string json, list specifiers) {
    return llRound(llPow(2.,(float)((integer)llGetSubString(
        llEscapeURL(llJsonValueType(json,specifiers)),8,8))));
}

// as long as it is not null or invalid, returns true
integer jsonValid(string value, list spec) {
    return (
        !(jsonType(value,spec) & (invalid | null))
    );
}

// Copy this file into an LSL script and replace
// all calls to llJsonGetValue() with jsonGetValue()
string jsonGetValue(string json, list spec) {
    if(jsonValid(json,spec)) return llJsonGetValue(json,spec);
    else return "";
}
