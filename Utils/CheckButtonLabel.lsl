// Truncates button labels longer than 24 bytes
string checkButtonLabel(string label) {
    // llStringLength returns character count, but labels are limited by byte length
    string encoded = llStringToBase64(label);
    
    // 32 chars in Base64 = 24 bytes of UTF-8 data
    if (llStringLength(encoded) <= 32) {
        return label; 
    }
    
    // Truncate to avoid an error
    return llBase64ToString(llGetSubString(encoded, 0, 31));
}
