// Rotating Sign ver. 2.0
// Created 02-Feb-2012 by Missy Restless
// Modified 26-Aug-2025 by Missy Restless
//   - Touch to start/stop rotation
//   - Sync client-side and server-side rotations
//   - Add configuration options to enable/disable setting of scale and textures
//
// Rotate about z-axis, periodically emit particle display, when touched
// optionally deliver a notecard, object, texture, sound, clothing, script,
// body part, animation, gesture, and landmark if present.
//

integer particles = 1;
integer give_notecard = 1;
integer give_landmark = 0;
integer give_object = 0;
integer give_texture = 0;
integer give_sound = 0;
integer give_clothing = 0;
integer give_script = 0;
integer give_bodypart = 0;
integer give_animation = 0;
integer give_gesture = 0;
integer hover_text = 1;
integer rotate = 1;
integer setscale = 0;
integer textures = 0;
integer use_particles = 1;
integer touch_enabled = 1;
integer auto_deliver = 0;
integer inform_on_arrival = 0;
string note_name = "";
string land_name = "";
string object_name = "";
string texture_name = "";
string sound_name = "";
string clothing_name = "";
string script_name = "";
string bodypart_name = "";
string animation_name = "";
string gesture_name = "";
string texture_front = "42cee9e5-fd85-636d-81f6-f8fb4141d921";
string texture_back = "c37cf05b-d1d4-cea9-20a0-fcaf389e1961";
string hoverText = "";
string group_key = "";
string group_message = "Click here to join our group:";
vector hoverColor = <0.0, 1.0, 0.0>;
float inc_x = 0.1;
float inc_y = 0.05;
float inc_z = 0.1;
float particle_duration = 30.0;
float particle_interval = 120.0;
float scan_interval = 60.0;
float range = 20.0;
vector start = <1.00000, 0.25000, 1.00000>;
vector end = <1.00000, 1.00000, 1.00000>;
vector accel = <1.00000, 1.00000, -1.00000>;
vector scale = <4.0, 0.01, 8.4>;

integer iOn;
integer iStep;

integer NotecardLine;
string CONFIG_CARD = "Config";
key D_QueryID;

list    gLstAvs; // List Of Avatars Keys Greeted //
list    vLstChk; // List Of Av Key Being Checked During Sensor Processing //
integer vIdxLst;        // Index Of Checked Item In List (reused) //

// PreSet to Ease Removing Dynamic Memory Limitation Code //
integer gIntMax = 1000;  // Maximum Number of Names To Store //

// Dynamic Memory Limitation Section //
integer int_MEM = 1000; // memory to preserve for safety //

// Start Av Culling Section //
integer gIntPrd = 172800; // Number Of Seconds After Detection To Store Av //
integer vIntNow;    // Integer To Store Current Time During Sensor Processing //
list    gLstTms;          // List Of Most Recent Times Avs Were Greeted At //
list    vLstTmt;          // List To Store Timeout During Sensor Processing //

bubbles_on() {
    llParticleSystem([
                        PSYS_PART_FLAGS, ( 0
                                         | PSYS_PART_EMISSIVE_MASK
                                         | PSYS_PART_INTERP_COLOR_MASK
                                         | PSYS_PART_INTERP_SCALE_MASK
                                         | PSYS_PART_FOLLOW_VELOCITY_MASK ),
                        PSYS_PART_MAX_AGE, 15,
                        PSYS_PART_START_COLOR, <1.00000, 0.25000, 1.00000>,
                        PSYS_PART_END_COLOR, <1.00000, 1.00000, 1.00000>,
                        PSYS_PART_START_SCALE, <.1,.1,.1>,
                        PSYS_PART_END_SCALE, <.6,.6,.9>,
                        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
                        PSYS_SRC_BURST_RATE, 0.1,
                        PSYS_SRC_ACCEL, <0.0, 0.0, 0.1>,
                        PSYS_SRC_BURST_PART_COUNT, 10,
                        PSYS_SRC_BURST_RADIUS, 1.000000,
                        PSYS_SRC_BURST_SPEED_MIN, 0.1,
                        PSYS_SRC_BURST_SPEED_MAX, 0.1,
                        PSYS_SRC_INNERANGLE, 1.55,
                        PSYS_SRC_OUTERANGLE, 1.54,
                        PSYS_SRC_OMEGA, <0.,0.,10.>,
                        PSYS_SRC_MAX_AGE, 0,
                        PSYS_SRC_TEXTURE, "",
                        PSYS_PART_START_ALPHA, 0.3,
                        PSYS_PART_END_ALPHA, 0.6
    ]);
}

part_one() {
    llParticleSystem([
            PSYS_PART_MAX_AGE, 2.000000,
            PSYS_PART_FLAGS, 259,
            PSYS_PART_START_COLOR, <1.0, 0.0, 0.0>,
            PSYS_PART_END_COLOR, <0.0, 0.0, 1.0>,
            PSYS_PART_START_SCALE, <0.010000, 0.010000, 0.00000>,
            PSYS_PART_END_SCALE, <0.20000, 2.00000, 0.00000>,
            PSYS_SRC_PATTERN, 2,
            PSYS_SRC_BURST_RATE, 0.01000,
            PSYS_SRC_ACCEL, <0.00000, 0.00000, 0.00000>,
            PSYS_SRC_BURST_PART_COUNT, 1,
            PSYS_SRC_BURST_RADIUS, 3.000000,
            PSYS_SRC_BURST_SPEED_MIN, 0.100000,
            PSYS_SRC_BURST_SPEED_MAX, 0.700000,
            PSYS_SRC_INNERANGLE, 3.141593,
            PSYS_SRC_OUTERANGLE, 6.283185,
            PSYS_SRC_OMEGA, <0.00000, 0.00000, 0.00000>,
            PSYS_SRC_MAX_AGE, 0.000000,
            PSYS_PART_START_ALPHA, 1.000000,
            PSYS_PART_END_ALPHA, 1.000000,
            PSYS_SRC_TEXTURE, "",
            PSYS_SRC_TARGET_KEY, (key)"",
            PSYS_PART_FLAGS, ( 0
                                | PSYS_PART_INTERP_COLOR_MASK
                                | PSYS_PART_INTERP_SCALE_MASK
                                | PSYS_PART_EMISSIVE_MASK
                                | PSYS_PART_FOLLOW_VELOCITY_MASK
                                | PSYS_PART_WIND_MASK
                            )
            ]);
}

part_two() {
    llParticleSystem([
           PSYS_SRC_TEXTURE, "",
           PSYS_PART_START_SCALE, <0.2, 0.2, FALSE>,
           PSYS_PART_END_SCALE, <0.5, 0.5, FALSE>,
           PSYS_PART_START_COLOR, <1.0, 0.0, 0.0>,
           PSYS_PART_END_COLOR, <0.0, 0.0, 1.0>,
           PSYS_PART_START_ALPHA, 1.0,
           PSYS_PART_END_ALPHA, 0.5,

           PSYS_SRC_BURST_PART_COUNT,   10,
           PSYS_SRC_BURST_RATE,        .1,
           PSYS_PART_MAX_AGE,         2.0,
           PSYS_SRC_MAX_AGE,          0.0,

           PSYS_SRC_PATTERN, 2,
           PSYS_SRC_BURST_SPEED_MIN, 0.5,
           PSYS_SRC_BURST_SPEED_MAX, 2.0,
           PSYS_SRC_BURST_RADIUS, 3.000000,

           PSYS_SRC_ANGLE_BEGIN,  0.05*PI,
           PSYS_SRC_ANGLE_END, 0.05*PI,
           PSYS_SRC_OMEGA, < 0.0, 0.0, 0.0 >,

           PSYS_SRC_ACCEL, < 0.0, 0.0, 0.0 >,
           PSYS_SRC_TARGET_KEY, (key)"",

           PSYS_PART_FLAGS, ( 0
                                | PSYS_PART_INTERP_COLOR_MASK
                                | PSYS_PART_INTERP_SCALE_MASK
                                | PSYS_PART_EMISSIVE_MASK
                                | PSYS_PART_FOLLOW_VELOCITY_MASK
                                | PSYS_PART_WIND_MASK
                            )
            ]
        );
}

flame_out() {
    llParticleSystem([
        PSYS_PART_MAX_AGE, 2.000000,
        PSYS_PART_FLAGS, 259,
        PSYS_PART_START_COLOR, start,
        PSYS_PART_END_COLOR, end,
        PSYS_PART_START_SCALE, <0.40000, 4.00000, 0.00000>,
        PSYS_PART_END_SCALE, <0.10000, 0.10000, 0.00000>,
        PSYS_SRC_PATTERN, 2,
        PSYS_SRC_BURST_RATE,0.001000,
        PSYS_SRC_ACCEL, accel,
        PSYS_SRC_BURST_PART_COUNT,1,
        PSYS_SRC_BURST_RADIUS, 1.000000,
        PSYS_SRC_BURST_SPEED_MIN,0.100000,
        PSYS_SRC_BURST_SPEED_MAX,0.700000,
        PSYS_SRC_INNERANGLE,3.141593,
        PSYS_SRC_OUTERANGLE,6.283185,
        PSYS_SRC_OMEGA,<0.00000, 0.00000, 0.00000>,
        PSYS_SRC_MAX_AGE,0.000000,
        PSYS_PART_START_ALPHA,1.000000,
        PSYS_PART_END_ALPHA,1.000000,
        PSYS_SRC_TEXTURE, "",
        PSYS_SRC_TARGET_KEY,(key)"" ]);
}

float round(float val) {
    if (val > 1.0)
      return (val - 1.0);
    else if (val < -1.0)
      return (val + 1.0);
    else
      return val;
}

inc_col() {
    start.x += inc_x;
    start.x = round(start.x);
    start.y += inc_y;
    start.y = round(start.y);
    start.z += inc_z;
    start.z = round(start.z);
    accel.x += inc_x;
    accel.x = round(accel.x);
    accel.y += inc_y;
    accel.y = round(accel.y);
    accel.z = -accel.z;
}

set_scale() {
    vector curr;
    curr = llGetScale();
    if ((curr.x == scale.x) && (curr.y == scale.y) && (curr.z == scale.z))
        return;
    else
        llSetScale(scale);
}

set_names() {
    integer num_items = 0;
    integer j;
    string name;

    if (note_name == "") {
        if (give_notecard) {
            num_items = llGetInventoryNumber(INVENTORY_NOTECARD);
            for (j=0; j<num_items;j++) {
                name = llGetInventoryName(INVENTORY_NOTECARD, j);
                if ((name != CONFIG_CARD) && (llGetInventoryType(name) == 7)) {
                    note_name = name;
                    j = num_items;
                }
            }
        }
    }
    if (land_name == "") {
        if (give_landmark) {
            name = llGetInventoryName(INVENTORY_LANDMARK, 0);
            if (llGetInventoryType(name) == 3)
                land_name = name;
        }
    }
    if (object_name == "") {
        if (give_object) {
            name = llGetInventoryName(INVENTORY_OBJECT, 0);
            if (llGetInventoryType(name) == 6)
                object_name = name;
        }
    }
    if (texture_name == "") {
        if (give_texture) {
            num_items = llGetInventoryNumber(INVENTORY_TEXTURE);
            for (j=0; j<num_items;j++) {
                name = llGetInventoryName(INVENTORY_TEXTURE, j);
                if ((name != texture_front) && (name != texture_back) &&
                    (llGetInventoryType(name) == 0)) {
                    texture_name = name;
                    j = num_items;
                }
            }
        }
    }
    if (sound_name == "") {
        if (give_sound) {
            name = llGetInventoryName(INVENTORY_SOUND, 0);
            if (llGetInventoryType(name) == 1)
                sound_name = name;
        }
    }
    if (clothing_name == "") {
        if (give_clothing) {
            name = llGetInventoryName(INVENTORY_CLOTHING, 0);
            if (llGetInventoryType(name) == 5)
                clothing_name = name;
        }
    }
    if (script_name == "") {
        if (give_script) {
            num_items = llGetInventoryNumber(INVENTORY_SCRIPT);
            for (j=0; j<num_items;j++) {
                name = llGetInventoryName(INVENTORY_SCRIPT, j);
                if ((name != llGetScriptName()) &&
                    (llGetInventoryType(name) == 10)) {
                    script_name = name;
                    j = num_items;
                }
            }
        }
    }
    if (bodypart_name == "") {
        if (give_bodypart) {
            name = llGetInventoryName(INVENTORY_BODYPART, 0);
            if (llGetInventoryType(name) == 13)
                bodypart_name = name;
        }
    }
    if (animation_name == "") {
        if (give_animation) {
            name = llGetInventoryName(INVENTORY_ANIMATION, 0);
            if (llGetInventoryType(name) == 20)
                animation_name = name;
        }
    }
    if (gesture_name == "") {
        if (give_gesture) {
            name = llGetInventoryName(INVENTORY_GESTURE, 0);
            if (llGetInventoryType(name) == 21)
                gesture_name = name;
        }
    }
}

deliver_items(key toucher) {
    if (give_notecard && (note_name != ""))
        llGiveInventory(toucher, note_name);
    if (give_landmark && (land_name != ""))
        llGiveInventory(toucher, land_name);
    if (give_object && (object_name != ""))
        llGiveInventory(toucher, object_name);
    if (give_texture && (texture_name != ""))
        llGiveInventory(toucher, texture_name);
    if (give_sound && (sound_name != ""))
        llGiveInventory(toucher, sound_name);
    if (give_clothing && (clothing_name != ""))
        llGiveInventory(toucher, clothing_name);
    if (give_script && (script_name != ""))
        llGiveInventory(toucher, script_name);
    if (give_bodypart && (bodypart_name != ""))
        llGiveInventory(toucher, bodypart_name);
    if (give_animation && (animation_name != ""))
        llGiveInventory(toucher, animation_name);
    if (give_gesture && (gesture_name != ""))
        llGiveInventory(toucher, gesture_name);
}

init_prim() {
    string owner_msg;

    if (setscale)
        set_scale();
    if (textures)
        llSetTexture(texture_front, 1);
        llSetTexture(texture_back, 3);
    if (rotate)
        llTargetOmega(<0.0,0.0,0.25>, 0.25, PI);
    set_names();
    hoverText = "Touch me for";
    owner_msg = "Sign initialized. Configured to deliver:";
    if (give_notecard && (note_name != "")) {
        hoverText = hoverText + " Notecard";
        owner_msg = owner_msg + "\nNotecard - " + note_name;
    }
    if (give_landmark && (land_name != "")) {
        if (hoverText == "Touch me for")
            hoverText = hoverText + " Landmark";
        else
            hoverText = hoverText + ", Landmark";
        owner_msg = owner_msg + "\nLandmark - " + land_name;
    }
    if (give_object && (object_name != "")) {
        if (hoverText == "Touch me for")
            hoverText = hoverText + " Object";
        else
            hoverText = hoverText + ", Object";
        owner_msg = owner_msg + "\nObject - " + object_name;
    }
    if (give_texture && (texture_name != "")) {
        if (hoverText == "Touch me for")
            hoverText = hoverText + " Texture";
        else
            hoverText = hoverText + ", Texture";
        owner_msg = owner_msg + "\nTexture - " + texture_name;
    }
    if (give_sound && (sound_name != "")) {
        if (hoverText == "Touch me for")
            hoverText = hoverText + " Sound";
        else
            hoverText = hoverText + ", Sound";
        owner_msg = owner_msg + "\nSound - " + sound_name;
    }
    if (give_bodypart && (bodypart_name != "")) {
        if (hoverText == "Touch me for")
            hoverText = hoverText + " Body Part";
        else
            hoverText = hoverText + ", Body Part";
        owner_msg = owner_msg + "\nBody Part - " + bodypart_name;
    }
    if (give_animation && (animation_name != "")) {
        if (hoverText == "Touch me for")
            hoverText = hoverText + " Animation";
        else
            hoverText = hoverText + ", Animation";
        owner_msg = owner_msg + "\nAnimation - " + animation_name;
    }
    if (give_gesture && (gesture_name != "")) {
        if (hoverText == "Touch me for")
            hoverText = hoverText + " Gesture";
        else
            hoverText = hoverText + ", Gesture";
        owner_msg = owner_msg + "\nGesture - " + gesture_name;
    }
    if (give_clothing && (clothing_name != "")) {
        if (hoverText == "Touch me for")
            hoverText = hoverText + " Clothing";
        else
            hoverText = hoverText + ", Clothing";
        owner_msg = owner_msg + "\nClothing Item - " + clothing_name;
    }
    if (give_script && (script_name != "")) {
        if (hoverText == "Touch me for")
            hoverText = hoverText + " Script";
        else
            hoverText = hoverText + ", Script";
        owner_msg = owner_msg + "\nScript - " + script_name;
    }
    if (hoverText == "Touch me for")
        hoverText = "";
    if (owner_msg == "Sign initialized. Configured to deliver:")
        llOwnerSay("No items appear to be configured for delivery.");
    else
        llOwnerSay(owner_msg);
    if (auto_deliver || inform_on_arrival)
        llSensorRepeat("", "", AGENT, range, PI, scan_interval);
    if (use_particles)
        llSetTimerEvent(particle_duration);
}

default
{
    on_rez(integer param) {
      llResetScript();
    }

    state_entry()
    {
      if (llGetInventoryType(CONFIG_CARD) == INVENTORY_NOTECARD) {
          NotecardLine = 0;
          D_QueryID = llGetNotecardLine( CONFIG_CARD, NotecardLine );
      }
      else {
          llOwnerSay("Configuration notecard missing, using defaults.");
          init_prim();
      }
    }

    dataserver( key queryid, string data )
    {
        list temp;
        string name;
        string value;
        if ( queryid == D_QueryID ) {
            if ( data != EOF ) {
                if (data == "END_SETTINGS") {
                    init_prim();
                    return;
                }
                if ( llGetSubString(data, 0, 0) != "#" &&
                     llStringTrim(data, STRING_TRIM) != "" ) {
                    temp = llParseString2List(data, ["="], []);
                    name = llStringTrim(llList2String(temp, 0), STRING_TRIM);
                    value = llStringTrim(llList2String(temp, 1), STRING_TRIM);
                    if ( value == "TRUE" ) value = "1";
                    if ( value == "FALSE" ) value = "0";
                    if ( name == "PARTICLE_DURATION" ) {
                        particle_duration = (float)value;
                    } else if ( name == "PARTICLE_INTERVAL" ) {
                        particle_interval = (float)value;
                    } else if ( name == "USE_PARTICLES" ) {
                        use_particles = (integer)value;
                    } else if ( name == "TOUCH_ENABLED" ) {
                        touch_enabled = (integer)value;
                    } else if ( name == "AUTO_DELIVER" ) {
                        auto_deliver = (integer)value;
                    } else if ( name == "INFORM_ON_ARRIVAL" ) {
                        inform_on_arrival = (integer)value;
                    } else if ( name == "SCAN_INTERVAL" ) {
                        scan_interval = (float)value;
                    } else if ( name == "RANGE" ) {
                        range = (float)value;
                    } else if ( name == "NOTECARD" ) {
                        if (llGetInventoryType(value) == 7)
                            note_name = value;
                    } else if ( name == "LANDMARK" ) {
                        if (llGetInventoryType(value) == 3)
                            land_name = value;
                    } else if ( name == "OBJECT" ) {
                        if (llGetInventoryType(value) == 6)
                            object_name = value;
                    } else if ( name == "TEXTURE" ) {
                        if (llGetInventoryType(value) == 0)
                            texture_name = value;
                    } else if ( name == "SOUND" ) {
                        if (llGetInventoryType(value) == 1)
                            sound_name = value;
                    } else if ( name == "CLOTHING" ) {
                        if (llGetInventoryType(value) == 5)
                            clothing_name = value;
                    } else if ( name == "SCRIPT" ) {
                        if (llGetInventoryType(value) == 10)
                            script_name = value;
                    } else if ( name == "BODYPART" ) {
                        if (llGetInventoryType(value) == 13)
                            bodypart_name = value;
                    } else if ( name == "ANIMATION" ) {
                        if (llGetInventoryType(value) == 20)
                            animation_name = value;
                    } else if ( name == "GESTURE" ) {
                        if (llGetInventoryType(value) == 21)
                            gesture_name = value;
                    } else if ( name == "GIVE_NOTECARD" ) {
                        give_notecard = (integer)value;
                    } else if ( name == "GIVE_LANDMARK" ) {
                        give_landmark = (integer)value;
                    } else if ( name == "GIVE_OBJECT" ) {
                        give_object = (integer)value;
                    } else if ( name == "GIVE_TEXTURE" ) {
                        give_texture = (integer)value;
                    } else if ( name == "GIVE_SOUND" ) {
                        give_sound = (integer)value;
                    } else if ( name == "GIVE_CLOTHING" ) {
                        give_clothing = (integer)value;
                    } else if ( name == "GIVE_SCRIPT" ) {
                        give_script = (integer)value;
                    } else if ( name == "GIVE_BODYPART" ) {
                        give_bodypart = (integer)value;
                    } else if ( name == "GIVE_ANIMATION" ) {
                        give_animation = (integer)value;
                    } else if ( name == "GIVE_GESTURE" ) {
                        give_gesture = (integer)value;
                    } else if ( name == "HOVER_TEXT" ) {
                        hover_text = (integer)value;
                    } else if ( name == "SET_SCALE" ) {
                        setscale = (integer)value;
                    } else if ( name == "SET_FRONT_BACK" ) {
                        textures = (integer)value;
                    } else if ( name == "TEXTURE_FRONT" ) {
                        if (llGetInventoryType(value) == 0) {
                            texture_front = value;
                        }
                        else if ((key)value) {
                            texture_front = value;
                        }
                    } else if ( name == "TEXTURE_BACK" ) {
                        if (llGetInventoryType(value) == 0) {
                            texture_back = value;
                        }
                        else if ((key)value) {
                            texture_back = value;
                        }
                    } else if ( name == "ROTATE" ) {
                        rotate = (integer)value;
                    } else if ( name == "WIDTH" ) {
                        scale.x = (float)value;
                    } else if ( name == "DEPTH" ) {
                        scale.y = (float)value;
                    } else if ( name == "HEIGHT" ) {
                        scale.z = (float)value;
                    } else if ( name == "GROUP_KEY" ) {
                        group_key = value;
                    } else if ( name == "GROUP_MESSAGE" ) {
                        group_message = value;
                    }
                }
                NotecardLine++;
                D_QueryID = llGetNotecardLine( CONFIG_CARD, NotecardLine );
            }
        }
    }

    // To make an object return to its initial rotation when target omega stops,
    // first make the object rotate both client side and server side. Then, when
    // you stop llTargetOmega, reset server side rotation. Here's one way to do it.
    touch_start(integer num_detect) {
        integer i;
        if (touch_enabled) {
            for (i=0;i<num_detect;i++) {
                deliver_items(llDetectedKey(i));
            }
        }
        iOn = !iOn;
        if (iOn) {
	    // Start rotating client side with llTargetOmega
            // llTargetOmega(<0.0,0.0,0.25>, 0.25, PI);
            llTargetOmega(<0.0,0.0,1.0>, PI/8, 1.0);
	    //Start timer to rotate server side
            llSetTimerEvent(1.0);
        }
        else {
	    //Stop client side rotation
            llTargetOmega(<0.0,0.0,1.0>, 0.0, 0.0);
	    //Stop timer and thus server side rotation
            llSetTimerEvent(0.0);
	    //Set server side rotation to <0.0,0.0,0.0>
            llSetRot(ZERO_ROTATION);
            iStep = 0;
        }
    }
    
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY)
        {
            llResetScript();
        }
    }

    timer()
    {
	// Rotate at the same speed as llTargetOmega
        llSetRot(llAxisAngle2Rot(<0.0,0.0,1.0> ,++iStep *PI/8));
        if (particles % 2) {
            llSetText("", hoverColor, 1.0);
            if (particles == 1) {
                flame_out();
                inc_col();
            } else if (particles == 3) {
                bubbles_on();
            } else if (particles == 5) {
                part_one();
            } else if (particles == 7) {
                part_two();
            }
            llSetTimerEvent(particle_duration);
        }
        else {
            llParticleSystem([]);
            if (hover_text && touch_enabled)
                llSetText(hoverText, hoverColor, 1.0);
            llSetTimerEvent(particle_interval);
        }
        particles++;
        if (particles > 7)
            particles = 0;
    }

    sensor(integer num_avis) {
        // Save Current Timer to Now, Then Add Period and Save To Timeout//
        vLstTmt = (list)(gIntPrd + (vIntNow = llGetUnixTime()));
        @Building; {
            // Is This Av Already In Our List? //
            if (~(vIdxLst = llListFindList(gLstAvs,
                 (vLstChk = (list)llDetectedKey(--num_avis))))) {
                // Delete The Old Entries & Add New Entries to Preserve Order //
                gLstAvs = llDeleteSubList(gLstAvs, vIdxLst, vIdxLst) + vLstChk;
                gLstTms = llDeleteSubList(gLstTms, vIdxLst, vIdxLst) + vLstTmt;
            }
            else {
                // New Av, Add Them To The Lists & Preserve Max List Size//
                key new_av = llDetectedKey(num_avis);
                if (inform_on_arrival && (!auto_deliver)) {
                    llInstantMessage(new_av, "Hello " +
                                     llKey2Name(new_av) + "! " + hoverText);
                }
                if ((key)group_key) {
                    if (group_key != "") {
                      llInstantMessage(new_av, group_message + " " +
                            "secondlife:///app/group/"+group_key+"/about");
                    }
                }
                if (auto_deliver) {
                    deliver_items(new_av);
                }
                gLstAvs = llList2List( vLstChk + gLstAvs, 0, gIntMax );
                gLstTms = llList2List( vLstTmt + gLstTms, 0, gIntMax );
            }
        }
        if (num_avis) jump Building;

        // Start Dynamic Memory Limitation Section //
        // Only lower Max List Size Once For Saftey //
        if (int_MEM == gIntMax) {
            // do we have plenty of room in the script? //
            if (int_MEM > llGetFreeMemory()){
                // running out of room, set the Max list size lower //
                gIntMax = ~([] != gLstAvs);
            }
        }
        // End Dynamic Memory Limitation Section //

        // Start Av Culling Section //
        // do we have keys? //
        if (vIdxLst = llGetListLength( gLstTms )) {
            // Do Any Need Culled? //
            if (vIntNow > llList2Integer( gLstTms, --vIdxLst )){
                // Find The Last Index that hasn't hit timeout status //
                @TheirBones;
                if (--vIdxLst)
                  if (vIntNow > llList2Integer(gLstTms, vIdxLst))
                      jump TheirBones;
                // Thin the herd //
                gLstAvs = llList2List( gLstAvs, 0, vIdxLst );
                gLstTms = llList2List( gLstTms, 0, vIdxLst );
            }
        }
        // End Av Culling Section //
    }
}
