// Snippets and HTTPRequest bits were taken from:
//~ RANDOM PROFILE PROJECTOR v5.4.5 by Debbie Trilling ~
 
// Get Profile Picture by Valentine Foxdale
// optmisation by SignpostMarv Martin
// workaround for WEB-1384 by Viktoria Dovgal:
//  try meta tag instead of img first, try img as backup in case meta breaks

list sides;
list deftextures;

string profile_key_prefix = "<meta name=\"imageid\" content=\"";
string profile_img_prefix = "<img alt=\"profile image\" src=\"http://secondlife.com/app/image/";
integer profile_key_prefix_length; // calculated from profile_key_prefix in state_entry()
integer profile_img_prefix_length; // calculated from profile_key_prefix in state_entry()

//Run the HTTP Request then set the texture
GetProfilePic(key id) {
    //key id=llDetectedKey(0); This breaks the function, better off not used
    string URL_RESIDENT = "https://world.secondlife.com/resident/";
    llHTTPRequest(URL_RESIDENT + (string)id, [HTTP_METHOD, "GET"], "");
}

//Get the default textures from each side
GetDefaultTextures() {
    integer    i;
    integer    faces = llGetNumberOfSides();
    for (i = 0; i < faces; i++) {
        sides += i;
        deftextures += llGetTexture(i);
    }
}

//Set the sides to their default textures
SetDefaultTextures() {
    integer    i;
    integer    faces;
    faces = llGetNumberOfSides();
    for (i = 0; i < faces; i++) {
        llSetTexture(llList2String(deftextures, i), i);
    }
}

default
{
    state_entry() {
        profile_key_prefix_length = llStringLength(profile_key_prefix);
        profile_img_prefix_length = llStringLength(profile_img_prefix);
        llSetText("Touch for this object to display your profile picture!", <0.8, 0, 1>, 1); 
        GetDefaultTextures();
    }

    touch_start(integer total_number) {
        GetProfilePic(llDetectedKey(0));
    }

    http_response(key req, integer stat, list met, string body) {
        integer s1 = llSubStringIndex(body, profile_key_prefix);
        integer s1l = profile_key_prefix_length;
        if (s1 == -1) { // second try
            s1 = llSubStringIndex(body, profile_img_prefix);
            s1l = profile_img_prefix_length;
        }
        
        if (s1 == -1) { // still no match?
            SetDefaultTextures();
        } else {
            s1 += s1l;
            key UUID=llGetSubString(body, s1, s1 + 35);
            if (UUID == NULL_KEY) {
                SetDefaultTextures();
            } else {
                llSetTexture(UUID, ALL_SIDES);
            }
        }
    }
}
