string GetAvatarGender(key avatar)
{
    list details = llGetObjectDetails(avatar, [OBJECT_BODY_SHAPE_TYPE]);
    if (details == []) return "not found";
    float gender = llList2Float(details, 0);
    if (gender < 0.0)   return "undefined (not an avatar)"; // agent not found
    if (gender == 0.0)  return "female";
    string rv = " (" + (string)gender + ")";
    if (gender < 0.5)   return "somewhat feminine" + rv;
    if (gender == 0.5)  return "androgynous" + rv;
    if (gender < 1.0)   return "somewhat masculine" + rv;
    return "male"; 
}

default
{
    touch_start(integer num_detected)
    {
        llWhisper(0, llDetectedName(0) + "'s shape is " + GetAvatarGender(llDetectedKey(0)));
    }
}