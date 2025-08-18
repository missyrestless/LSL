// Email2IM - relay an incoming email message body via IM to the email Subject.
// Copyright (c) 2011 Missy Restless
//
// This is a basic script to translate emails into IMs. When initiated, 
// the script says an email address, which is the UUID for the prim containing 
// the script along with the lsl email domain. The body of any email sent to 
// the address will be relayed as an object IM to the Subject of the email.
//
// The prim containing this script must have a stable UUID for longterm 
// continued usage. If the object is taken into inventory and re-rezed then
// a new email address will be issued and the previous one will no longer work.
//
// Created 06-Feb-2011 by Missy Restless - IM the resident specified in the
//     Subject field
// Modified 09-Feb-2011 by Missy Restless - change shapes and textures; read
//     configuration notecard for some defaults
 
////////// globals //////////
key owner;
key httpqkey;
string message = "";
string name = "";
string sender = "";
string MarketURL = "http://tinyurl.com/4h6gvqk";
// Name2Key server URL
string name2key_url = "http://w-hat.com/name2key";
// index of texture to use
integer texture = 0;
integer shape = 1;
integer num_textures = 0;
integer change_count = 1;
// Prim geometry parameters
vector cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
float hollow = 0.0;                    // 0.0 to 0.95
vector twist = <0.0, 0.0, 0.0>;          // -1.0 to 1.0
vector holesize = <1.0, 0.05, 0.0>;    // max X:1.0 Y:0.5
vector topshear = <0.0, 0.0, 0.0>;     // -0.5 to 0.5
vector profilecut = <0.0, 0.0, 0.0>;   // 0.0 to 1.0
vector taper_a = <0.0, 0.0, 0.0>;      // 0.0 to 1.0
vector dimple = <0.0, 1.0, 0.0>;
float revolutions = 3.0;               // 1.0 to 4.0
float radiusoffset = 1.0;              // -1.0 to 1.0
float skew = 0.0;                      // 
float glow = 0.05;
// Prim material parameters
integer soft = 2;
float gravity = 0.3;
float friction = 2.0;
float wind = 0.2;
float tension = 1.0;
vector force = <0.1, 0.1, 0.1>;
float inc = 0.05;
// Configuration Notecard
integer change_multiple = 1;
float interval = 120.0;
integer hover_text = 1;
integer rotate = 1;
integer simple = 0;
string size = "default";
string deftxt = "Instant Message";
string CONFIG_CARD = "Email2IM_Config";
integer NotecardLine;
key D_QueryID;
 
Box() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.0;                    // 0.0 to 0.95
    twist = <0.0, 0.0, 0.0>;          // -1.0 to 1.0
    taper_a = <1.0, 1.0, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.0, 0.0>;    // max X:1.0 Y:0.5
    glow = 0.05;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_BOX, PRIM_HOLE_DEFAULT,
                          cut, hollow, twist, taper_a, topshear]);
}

Holy_Box() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.0;                    // 0.0 to 0.95
    twist = <0.0, 0.0, 0.0>;          // -1.0 to 1.0
    taper_a = <0.0, 1.0, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 1.0, 0.0>;    // max X:1.0 Y:0.5
    glow = 0.1;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_BOX, PRIM_HOLE_DEFAULT,
                          cut, hollow, twist, taper_a, topshear]);
}

Cylinder() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.7;                    // 0.0 to 0.95
    twist = <0.0, 0.0, 0.0>;          // -1.0 to 1.0
    taper_a = <1.0, 1.0, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.0, 0.0>;    // max X:1.0 Y:0.5
    glow = 0.05;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_CYLINDER, PRIM_HOLE_SQUARE,
                          cut, hollow, twist, taper_a, topshear]);
}

Cylinder2() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.7;                    // 0.0 to 0.95
    twist = <-1.0, 1.0, 0.0>;          // -1.0 to 1.0
    taper_a = <1.0, 0.4, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.4, 0.0>;    // max X:1.0 Y:0.5
    glow = 0.05;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_CYLINDER, PRIM_HOLE_SQUARE,
                          cut, hollow, twist, taper_a, topshear]);
}

Prism() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.9;                    // 0.0 to 0.95
    twist = <0.0, 0.0, 0.0>;          // -1.0 to 1.0
    taper_a = <0.0, 0.0, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.0, 0.0>;    // max X:1.0 Y:0.5
    glow = 0.05;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_PRISM, PRIM_HOLE_TRIANGLE,
                          cut, hollow, twist, taper_a, topshear]);
}

Prism2() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.3;                    // 0.0 to 0.95
    twist = <-1.0, 1.0, 0.0>;          // -1.0 to 1.0
    taper_a = <1.0, 0.4, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.4, 0.0>;    // max X:1.0 Y:0.5
    glow = 0.05;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_PRISM, PRIM_HOLE_TRIANGLE,
                          cut, hollow, twist, taper_a, topshear]);
}

Sphere() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.0;                    // 0.0 to 0.95
    twist = <0.0, 0.0, 0.0>;          // -1.0 to 1.0
    dimple = <0.0, 1.0, 0.0>;    // max X:1.0 Y:0.5
    glow = 0.05;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_SPHERE, PRIM_HOLE_DEFAULT,
                          cut, hollow, twist, dimple]);
}

Ribbon() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 95.0;                    // 0.0 to 0.95
    twist = <-1.0, 1.0, 0.0>;          // -1.0 to 1.0
    dimple = <0.7, 1.0, 0.0>;    // max X:1.0 Y:0.5
    glow = 0.15;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_SPHERE, PRIM_HOLE_DEFAULT,
                          cut, hollow, twist, dimple]);
}

Infinity() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 95.0;                    // 0.0 to 0.95
    twist = <0.0, 1.0, 0.0>;          // -1.0 to 1.0
    dimple = <0.0, 0.05, 0.0>;    // max X:1.0 Y:0.5
    glow = 0.15;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_SPHERE, PRIM_HOLE_DEFAULT,
                          cut, hollow, twist, dimple]);
}

Spiral() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.0;                    // 0.0 to 0.95
    twist = <0.0, 0.0, 0.0>;          // -1.0 to 1.0
    holesize = <1.0, 0.05, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.0, 0.0>;     // -0.5 to 0.5
    profilecut = <0.0, 0.0, 0.0>;   // 0.0 to 1.0
    taper_a = <0.0, 0.0, 0.0>;      // 0.0 to 1.0
    revolutions = 3.0;               // 1.0 to 4.0
    radiusoffset = 1.0;              // -1.0 to 1.0
    skew = 0.0;                      // 
    glow = 0.15;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_TORUS, PRIM_HOLE_DEFAULT,
                          cut, hollow, twist, holesize, topshear, profilecut,
                          taper_a, revolutions, radiusoffset, skew]);
}

Barrel() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.0;                    // 0.0 to 0.95
    twist = <0.0, 0.0, 0.0>;          // -1.0 to 1.0
    holesize = <1.0, 0.25, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.0, 0.0>;     // -0.5 to 0.5
    profilecut = <0.0, 1.0, 0.0>;   // 0.0 to 1.0
    taper_a = <0.0, 0.0, 0.0>;      // 0.0 to 1.0
    revolutions = 1.0;               // 1.0 to 4.0
    radiusoffset = 0.0;              // -1.0 to 1.0
    skew = 0.0;                      // 
    glow = 0.05;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_TORUS, PRIM_HOLE_DEFAULT,
                          cut, hollow, twist, holesize, topshear, profilecut,
                          taper_a, revolutions, radiusoffset, skew]);
}

Double_Knot() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 95.0;                    // 0.0 to 0.95
    twist = <-1.0, 1.0, 0.0>;          // -1.0 to 1.0
    holesize = <0.05, 0.5, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.0, 0.0>;     // -0.5 to 0.5
    profilecut = <0.18, 0.2, 0.0>;   // 0.0 to 1.0
    taper_a = <0.0, 0.5, 0.0>;      // 0.0 to 1.0
    revolutions = 4.0;               // 1.0 to 4.0
    radiusoffset = 0.0;              // -1.0 to 1.0
    skew = 0.95;                      // 
    glow = 0.15;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_TORUS, PRIM_HOLE_DEFAULT,
                          cut, hollow, twist, holesize, topshear, profilecut,
                          taper_a, revolutions, radiusoffset, skew]);
}

Target() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 30.0;                    // 0.0 to 0.95
    twist = <-1.0, 1.0, 0.0>;          // -1.0 to 1.0
    holesize = <0.15, 0.5, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.0, 0.0>;     // -0.5 to 0.5
    profilecut = <0.125, 0.9, 0.0>;   // 0.0 to 1.0
    taper_a = <0.0, 0.5, 0.0>;      // 0.0 to 1.0
    revolutions = 4.0;               // 1.0 to 4.0
    radiusoffset = 0.0;              // -1.0 to 1.0
    skew = 0.95;                      // 
    glow = 0.15;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_TORUS, PRIM_HOLE_DEFAULT,
                          cut, hollow, twist, holesize, topshear, profilecut,
                          taper_a, revolutions, radiusoffset, skew]);
}

Flower() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.0;                    // 0.0 to 0.95
    twist = <-1.0, 1.0, 0.0>;          // -1.0 to 1.0
    holesize = <1.0, 0.5, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.0, 0.0>;     // -0.5 to 0.5
    profilecut = <0.0, 1.0, 0.0>;   // 0.0 to 1.0
    taper_a = <0.0, 0.0, 0.0>;      // 0.0 to 1.0
    revolutions = 1.0;               // 1.0 to 4.0
    radiusoffset = 0.0;              // -1.0 to 1.0
    skew = 0.0;                      // 
    glow = 0.1;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_TUBE,
                        PRIM_HOLE_DEFAULT,
                        cut, hollow, twist, holesize, topshear,
                        profilecut, taper_a, revolutions,
                        radiusoffset, skew]);
}

Tube() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.0;                    // 0.0 to 0.95
    twist = <0.0, 1.0, 0.0>;          // -1.0 to 1.0
    holesize = <1.0, 0.25, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.0, 0.0>;     // -0.5 to 0.5
    profilecut = <0.25, 1.0, 0.0>;   // 0.0 to 1.0
    taper_a = <0.0, 0.0, 0.0>;      // 0.0 to 1.0
    revolutions = 1.0;               // 1.0 to 4.0
    radiusoffset = 0.0;              // -1.0 to 1.0
    skew = 0.0;                      // 
    glow = 0.05;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_TUBE,
                        PRIM_HOLE_DEFAULT,
                        cut, hollow, twist, holesize, topshear,
                        profilecut, taper_a, revolutions,
                        radiusoffset, skew]);
}

Wave() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.0;                    // 0.0 to 0.95
    twist = <0.0, 0.0, 0.0>;          // -1.0 to 1.0
    holesize = <1.0, 0.05, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.0, 0.0>;     // -0.5 to 0.5
    profilecut = <0.0, 1.0, 0.0>;   // 0.0 to 1.0
    taper_a = <0.0, 0.0, 0.0>;      // 0.0 to 1.0
    revolutions = 3.0;               // 1.0 to 4.0
    radiusoffset = 0.0;              // -1.0 to 1.0
    skew = 0.95;                      // 
    glow = 0.15;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_RING,
                        PRIM_HOLE_DEFAULT,
                        cut, hollow, twist, holesize, topshear,
                        profilecut, taper_a, revolutions, 
                        radiusoffset, skew]);
}

Ring() {
    cut = <0.0, 1.0, 0.0>;          // 0.0 to 1.0
    hollow = 0.0;                    // 0.0 to 0.95
    twist = <0.0, 0.0, 0.0>;          // -1.0 to 1.0
    holesize = <1.0, 0.25, 0.0>;    // max X:1.0 Y:0.5
    topshear = <0.0, 0.0, 0.0>;     // -0.5 to 0.5
    profilecut = <0.0, 1.0, 0.0>;   // 0.0 to 1.0
    taper_a = <0.0, 0.0, 0.0>;      // 0.0 to 1.0
    revolutions = 1.0;               // 1.0 to 4.0
    radiusoffset = 0.0;              // -1.0 to 1.0
    skew = 0.0;                      // 
    glow = 0.05;
    llSetPrimitiveParams([PRIM_TYPE, PRIM_TYPE_RING,
                        PRIM_HOLE_DEFAULT,
                        cut, hollow, twist, holesize, topshear,
                        profilecut, taper_a, revolutions, 
                        radiusoffset, skew]);
}

Fade(float a_start, float a_end, integer faces, float speed)
{
    float temp_glow;
    llSetPrimitiveParams([PRIM_FLEXIBLE, TRUE, soft, gravity, friction,
                          wind, tension, force]);
    if(a_start < a_end)
    {
        temp_glow = 0.0;
        for(;a_start < a_end;)
        {
            a_start += speed;
            llSetAlpha(a_start, faces);
            temp_glow =  temp_glow + (speed * glow);
            if (temp_glow > 1.0) temp_glow = 1.0;
            llSetPrimitiveParams([PRIM_GLOW, ALL_SIDES, temp_glow]);
        }
        llSetPrimitiveParams([PRIM_FLEXIBLE, FALSE, soft, gravity, friction,
                              wind, tension, force]);
        llSetPrimitiveParams([PRIM_GLOW, ALL_SIDES, glow]);
        return;
    }
    else if(a_start > a_end)
    {
        temp_glow = glow;
        for(;a_start > a_end;)
        {
            a_start -= speed;
            llSetAlpha(a_start, faces);
            temp_glow =  temp_glow - (speed * glow);
            if (temp_glow < 0.0) temp_glow = 0.0;
            llSetPrimitiveParams([PRIM_GLOW, ALL_SIDES, temp_glow]);
        }
        llSetPrimitiveParams([PRIM_FLEXIBLE, FALSE, soft, gravity, friction,
                              wind, tension, force]);
        return;
    }
}

change_shape() {
    if (change_multiple == 0)
        return;
    Fade(1.0, 0.0, ALL_SIDES, inc);
    shape++;
    if (shape > 17)
        shape = 1;
    if (shape == 1) {
        Box();
        change_rotation();
        change_texture();
    }
    else if (shape == 2)
        Holy_Box();
    else if (shape == 3)
        Cylinder();
    else if (shape == 4)
        Cylinder2();
    else if (shape == 5)
        Prism();
    else if (shape == 6)
        Prism2();
    else if (shape == 7)
        Sphere();
    else if (shape == 8)
        Ribbon();
    else if (shape == 9)
        Infinity();
    else if (shape == 10)
        Spiral();
    else if (shape == 11)
        Barrel();
    else if (shape == 12)
        Double_Knot();
    else if (shape == 13)
        Target();
    else if (shape == 14)
        Flower();
    else if (shape == 15)
        Tube();
    else if (shape == 16)
        Wave();
    else if (shape == 17)
        Ring();
    Fade(0.0, 1.0, ALL_SIDES, inc);
}

change_rotation() {
    if (rotate)
        llTargetOmega(<llFrand(1.0),llFrand(1.0),llFrand(1.0)>, PI / 4.0, 1.0);
}

change_texture() {
    if (num_textures == 0)
        return;
    texture++;
    if (texture >= num_textures)
        texture = 0;
    llSetPrimitiveParams([PRIM_TEXTURE, ALL_SIDES,
                         llGetInventoryName(INVENTORY_TEXTURE, texture),
                         <1.0,1.0,0.0>, <0.0,0.0,0.0>, 0.0]);
}

SetSize(float scale) {
    llSetPrimitiveParams([PRIM_SIZE, <scale, scale, scale>]);
}

Sell(key av) {
    llInstantMessage(av, llKey2Name(owner) + " uses this object to respond to IM's via email. You can purchase one for yourself at " + MarketURL);
}

default {
    state_entry() {
        rotate = 1;
        change_multiple = 1;
        simple = 0;
        if (llGetInventoryType(CONFIG_CARD) == INVENTORY_NOTECARD) {
            NotecardLine = 0;
            D_QueryID = llGetNotecardLine( CONFIG_CARD, NotecardLine );
        }
        else {
            llOwnerSay("Email2IM configuration notecard missing, using defaults.");
        }
        num_textures = llGetInventoryNumber(INVENTORY_TEXTURE);
        texture = (integer)llFrand((float)num_textures);
        if (!simple) {
            change_rotation();
            change_texture();
            change_shape();
        }
        owner = llGetOwner();
        string address = (string)llGetKey() + "@lsl.secondlife.com";
        if (hover_text)
            llSetText("Email2IM Server\nOnline", <0.25, 1.0, 0.25>, 1.0);
        else
            llSetText("", <0.25, 1.0, 0.25>, 1.0);
        llOwnerSay("Now online.  The Email-to-IM address for " + llKey2Name(owner) + " is:\n" + address);
        llSetTimerEvent(interval);
    }

    on_rez(integer start_param) {
        llResetScript();
    }

    dataserver( key queryid, string data )
    {
        list temp;
        string name;
        string value;
        if ( queryid == D_QueryID ) {
            if ( data != EOF ) {
                if (data == "END_SETTINGS") {
                    return;
                }
                if ( llGetSubString(data, 0, 0) != "#" &&
                     llStringTrim(data, STRING_TRIM) != "" ) {
                    temp = llParseString2List(data, ["="], []);
                    name = llStringTrim(llList2String(temp, 0), STRING_TRIM);
                    value = llStringTrim(llList2String(temp, 1), STRING_TRIM);
                    if ( value == "TRUE" ) value = "1";
                    if ( value == "FALSE" ) value = "0";
                    if ( name == "INTERVAL" ) {
                        interval = (float)value;
                        llSetTimerEvent(interval);
                    }
                    else if ( name == "MULTIPLE" ) {
                        change_multiple = (integer)value;
                    }
                    else if ( name == "HOVER_TEXT" ) {
                        hover_text = (integer)value;
                        if (hover_text)
                            llSetText("Email2IM Server\nOnline",
                                       <0.25, 1.0, 0.25>, 1.0);
                        else
                            llSetText("", <0.25, 1.0, 0.25>, 1.0);
                    }
                    else if ( name == "ROTATE" ) {
                        rotate = (integer)value;
                        if (rotate)
                            change_rotation();
                        else
                            llTargetOmega(<0,0,0>, 0.0, 1.0);
                    }
                    else if ( name == "SENDER" ) {
                        sender = value;
                    }
                    else if ( name == "SIZE" ) {
                        size = value;
                        if (size == "tiny")
                            SetSize(0.1);
                        if (size == "small")
                            SetSize(0.5);
                        else if (size == "medium")
                            SetSize(1.0);
                        else if (size == "large")
                            SetSize(2.0);
                        else if (size == "XL")
                            SetSize(3.0);
                        else if (size == "XXL")
                            SetSize(4.0);
                    }
                    else if ( name == "SIMPLE" ) {
                        simple = (integer)value;
                        if (simple) {
                            change_multiple = 0;
                            rotate = 0;
                            llTargetOmega(<0,0,0>, 0.0, 1.0);
                            Box();
                            if (size == "default")
                                SetSize(0.5);
                            if (llGetInventoryType(deftxt) == INVENTORY_TEXTURE)
                                  llSetPrimitiveParams([PRIM_TEXTURE, ALL_SIDES,
                                      deftxt, <1.0,1.0,0.0>, <0.0,0.0,0.0>, 0.0,
                                      PRIM_GLOW, ALL_SIDES, glow]);
                        }
                        else {
                            rotate = 1;
                            change_rotation();
                        }
                    }
                }
                NotecardLine++;
                D_QueryID = llGetNotecardLine( CONFIG_CARD, NotecardLine );
            }
        }
    }

    touch_start(integer num_detect) {
        key toucher = llDetectedKey(0);
        if (toucher == owner) {
            state off;
        }
        else {
            Sell(toucher);
        }
    }

    email(string tm, string from, string subject, string body, integer rem) {
        llOwnerSay("Attempting to find key for " + subject);
        message = body;
        name = subject;
        httpqkey = llHTTPRequest(name2key_url + "?terse=1&name=" +
                                 llEscapeURL(subject), [], "");
        if (rem > 0)
            llGetNextEmail(sender, "");
    }

    http_response(key request_id, integer status, list metadata, string body)
    {  
        if (request_id == httpqkey) { // A key has arrived
            if ( status == 499 ) {
                llInstantMessage(owner,
                                 "name2key request timed out for " + name);
            }
            else if ( status != 200 ) {
                llInstantMessage(owner,
                                 "the internet exploded!! Blame " + name);
            }
            else if ( (key)body == NULL_KEY ) {
                llInstantMessage(owner, "No key found for " + name);
            }
            else {
                if (body == "") {
                    llInstantMessage(owner,
                                 "Unable to determine the Avatar key to use.");
                    return;
                }
                llInstantMessage(owner, "Key found for " + name);
                llInstantMessage((key)body, llKey2Name(owner)
                             + " is not online but has emailed you this IM :\n"
                             + message);
            }
        }
    }

    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)
        {
            llResetScript();
        }
    }

    timer() {
        change_count++;
        if (change_count > change_multiple)
            change_count = 1;
        if (change_count == 1)
            change_shape();
        llGetNextEmail(sender, "");
    }

    state_exit() {
        llSetTimerEvent(0.0);
        if (hover_text)
            llSetText("Email2IM Server\nOffline", <1.0, 0.25, 0.25>, 1.0);
        else
            llSetText("", <0.25, 1.0, 0.25>, 1.0);
    }
}
 
state off {
    state_entry() {
        Ribbon();
        change_rotation();
        change_texture();
        llTargetOmega(<0,0,0>, 0.0, 1.0);
    }

    touch_start(integer num_detect) {
        key toucher = llDetectedKey(0);
        if (toucher == owner) {
            state default;
        }
        else {
            Sell(toucher);
        }
    }

    on_rez(integer start_param) {
        llResetScript();
    }

    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)
        {
            llResetScript();
        }
    }
}

