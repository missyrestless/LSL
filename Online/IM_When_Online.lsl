// IM_When_Online - send an IM to the owner when the specified avatar logs on or off
// Written 13-May-2026 by Missy Restless
//
// UUID of the avatar to track
key TargetUuid = NULL_KEY;
// Name of the avatar to track
string TargetDisplayName = "";
// How often to check in seconds (60s minimum recommended)
float CheckInterval = 120.0; 
// ---------------------
// Default fallbacks if not set in configuration notecard
key Default_Uuid = "3506213c-29c8-4aa1-a38f-e12f6d41b804";

key AgentDataRequestID;
integer IsOnline = FALSE; // Assume offline initially
integer GetDisplayName = TRUE;
integer Debug = FALSE;
integer HoverText = TRUE;
integer NotecardLine;
string CONFIG_CARD = "Target_Config";
key D_QueryID;
key owner;
key display_name_query;

// Built-in white texture UUID
string WHT_UUID = "5748decc-f629-461c-9a36-a35a221fe21f";
vector RED = <1,0,0>;
vector GRN = <0,1,0>;

string profileURL;
string profile_key_prefix = "<meta name=\"imageid\" content=\"";
string profile_img_prefix = "<img alt=\"profile image\" src=\"http://secondlife.com/app/image/";
integer profile_key_prefix_length; // calculated from profile_key_prefix in state_entry()
integer profile_img_prefix_length; // calculated from profile_key_prefix in state_entry()

StatusUpdate() {
    // Request online status data for the specified user key
    if (Debug) {
      llOwnerSay("Calling llRequestAgentData with TargetUuid = " + (string)TargetUuid);
    }
    AgentDataRequestID = llRequestAgentData(TargetUuid, DATA_ONLINE);
    if (Debug) {
      llOwnerSay("Return from llRequestAgentData with AgentDataRequestID = " + (string)AgentDataRequestID);
    }
}

GetProfilePic(key id) //Run the HTTP Request then set the texture
{
    string URL_RESIDENT = "https://world.secondlife.com/resident/";
    llHTTPRequest(URL_RESIDENT + (string)id,[HTTP_METHOD,"GET"],"");
}

SetSideTextures(vector col) // Set the sides to the online status texture
{
    integer    i;
    integer    faces = llGetNumberOfSides();
    for (i = 0; i < faces; i++) {
        if (i == 0) {
            llSetColor(<1.0, 1.0, 1.0>, i);
            if (col == RED) {
                llSetPrimitiveParams([PRIM_FULLBRIGHT, i, FALSE]);
            } else {
                llSetPrimitiveParams([PRIM_FULLBRIGHT, i, TRUE]);
            }
        } else {
            llSetTexture(WHT_UUID, i);
            llSetColor(col, i);
            llSetPrimitiveParams([PRIM_GLOW, i, 0.1]);
        }
    }
}

SetDefaultTextures() // Set the sides to their default textures
{
    // Color the root prim red
    llSetTexture(WHT_UUID, ALL_SIDES);
    llSetColor(RED, ALL_SIDES);
}

profile_timer_init() {
    if (HoverText) {
        llSetText(TargetDisplayName + "\nChecking status...", <1.0, 1.0, 1.0>, 1.0); // Initial hover text
    } else {
        // Clear any previously set hover text
        llSetText("", <0,0,0>, 0.0);
    }
    GetProfilePic(TargetUuid);
    // Start monitoring immediately
    llSetTimerEvent(CheckInterval);
    // Do an initial check immediately
    StatusUpdate();
}

init_target() {
    SetDefaultTextures();
    if ((TargetUuid == NULL_KEY) || (TargetUuid == "target-avatar-uuid")) {
        TargetUuid = Default_Uuid;
    }
    profileURL = "secondlife:///app/agent/" + (string)TargetUuid + "/about";
    if (GetDisplayName) {
        display_name_query = llRequestDisplayName(TargetUuid);
    } else {
        llOwnerSay("Tracking " + profileURL + " online status");
        profile_timer_init();
    }
}

default
{
    on_rez(integer param) {
      llResetScript();
    }

    state_entry()
    {
      owner = llGetOwner();
      profile_key_prefix_length = llStringLength(profile_key_prefix);
      profile_img_prefix_length = llStringLength(profile_img_prefix);
      if (llGetInventoryType(CONFIG_CARD) == INVENTORY_NOTECARD) {
          NotecardLine = 0;
          D_QueryID = llGetNotecardLine( CONFIG_CARD, NotecardLine );
      }
      else {
          llOwnerSay("Configuration notecard missing, using defaults.");
          init_target();
      }
    }

    timer()
    {
      // Periodically check status
      StatusUpdate();
    }

    // Allows a touch to force an immediate update
    touch_start(integer num) {
      // Check if the first person who touched is the owner
      if (llDetectedKey(0) == owner)
      {
        HoverText = !HoverText;
        llOwnerSay("Tracking " + profileURL + " online status");
        StatusUpdate();
      }
    }

    dataserver(key queryid, string data)
    {
        if (queryid == AgentDataRequestID)
        {
            integer CurrentlyOnline;

            // Requested data contains the string "0" or "1" for DATA_ONLINE
            // Convert it to an integer and use the boolean as index
            // list index = [   0,       1,     2(0+2), 3(1+2)  ]
            list stat_cols = ["OFFLINE","ONLINE",RED,GRN];

            CurrentlyOnline = (integer)data;
            if (Debug) {
              llOwnerSay("In dataserver with CurrentlyOnline = " + (string)CurrentlyOnline);
              llOwnerSay("IsOnline = " + (string)IsOnline);
            }

            // Set hover text status and color
            string stats = llList2String(stat_cols, CurrentlyOnline);   // boolean/index = 0   or 1
            vector color = llList2Vector(stat_cols, CurrentlyOnline+2); // boolean/index = 0+2 or 1+2
            SetSideTextures(color);

            // IM if status has changed
            if (CurrentlyOnline)
            {
                if (!IsOnline)
                {
                    llInstantMessage(owner, profileURL + " is now ONLINE.");
                }
            }
            else
            {
                if (IsOnline)
                {
                    llInstantMessage(owner, profileURL + " is now OFFLINE.");
                }
            }
            // Set hover text
            if (HoverText) {
              if (Debug) {
                llOwnerSay("Setting hover text with status = " + stats);
              }
              llSetText(TargetDisplayName + "\nStatus: " + stats, color, 1.0); // Update hover text and color
            }

            // Update status
            IsOnline = CurrentlyOnline;
        }
        else if (queryid == D_QueryID)
        {
            string name;
            string value;
            list temp;
            if ( data != EOF ) {
                if (data == "END_SETTINGS") {
                    init_target();
                    return;
                }
                if ( llGetSubString(data, 0, 0) != "#" &&
                     llStringTrim(data, STRING_TRIM) != "" ) {
                    temp = llParseString2List(data, ["="], []);
                    name = llStringTrim(llList2String(temp, 0), STRING_TRIM);
                    value = llStringTrim(llList2String(temp, 1), STRING_TRIM);
                    if ( value == "TRUE" ) value = "1";
                    if ( value == "FALSE" ) value = "0";
                    if ( name == "TARGET_UUID" ) {
                        TargetUuid = (key)value;
                    } else if ( name == "TARGET_NAME" ) {
                        TargetDisplayName = value;
                        GetDisplayName = FALSE;
                    } else if ( name == "CHECK_INTERVAL" ) {
                        CheckInterval = (float)value; 
                    } else if ( name == "HOVER_TEXT" ) {
                        HoverText = (integer)value; 
                    } else if ( name == "DEBUG" ) {
                        Debug = (integer)value; 
                    }
                }
                NotecardLine++;
                D_QueryID = llGetNotecardLine( CONFIG_CARD, NotecardLine );
            }
        }
        else if (display_name_query == queryid)
        {
            TargetDisplayName = data;
            llOwnerSay("Tracking " + profileURL + " online status");
            profile_timer_init();
        }
    }

    changed(integer change)
    {
         if (change & (CHANGED_OWNER | CHANGED_INVENTORY))
         {
             llResetScript();
         }
    }

    http_response(key req,integer stat, list met, string body)
    {
        integer s1 = llSubStringIndex(body, profile_key_prefix);
        integer s1l = profile_key_prefix_length;
        if(s1 == -1)
        { // second try
            s1 = llSubStringIndex(body, profile_img_prefix);
            s1l = profile_img_prefix_length;
        }

        if(s1 == -1)
        { // still no match?
            SetDefaultTextures();
        }
        else
        {
            s1 += s1l;
            key UUID=llGetSubString(body, s1, s1 + 35);
            if (UUID == NULL_KEY) {
                SetDefaultTextures();
            }
            else {
                llSetTexture(UUID, 0);
            }
        }
    }
}
