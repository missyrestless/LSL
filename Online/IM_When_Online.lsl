// UUID of the avatar to track
key TargetUuid = NULL_KEY;
// Name of the avatar to track
string TargetName = "";
// How often to check in seconds (60s minimum recommended)
float CheckInterval = 600.0; 
// ---------------------
// Default fallbacks if not set in configuration notecard
key Default_Uuid = "3506213c-29c8-4aa1-a38f-e12f6d41b804";
string Default_Name = "Missy Angel (missy.restless)";

key AgentDataRequestID;
integer IsOnline = FALSE; // Assume offline initially

integer NotecardLine;
string CONFIG_CARD = "Target_Config";
key D_QueryID;

init_target() {
  if ((TargetUuid == NULL_KEY) || (TargetUuid == "target-avatar-uuid")) {
    TargetUuid = Default_Uuid;
  }
  if ((TargetName == "") || (TargetName == "Target Avatar Name")) {
    TargetName = Default_Name;
  }
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
          init_target();
      }
      // Start monitoring immediately
      llSetTimerEvent(CheckInterval);
      // Do an initial check immediately
      AgentDataRequestID = llRequestAgentData(TargetUuid, DATA_ONLINE);
    }

    timer()
    {
      // Periodically check status
      AgentDataRequestID = llRequestAgentData(TargetUuid, DATA_ONLINE);
    }

    dataserver(key queryid, string data)
    {
        list temp;
        string name;
        string value;

        if (queryid == AgentDataRequestID)
        {
            integer CurrentlyOnline = (integer)data;

            // If they just came online and were previously offline
            if (CurrentlyOnline && !IsOnline)
            {
                llInstantMessage(llGetOwner(), TargetName + " is now ONLINE.");
            }
            else if (!CurrentlyOnline && IsOnline)
            {
                llInstantMessage(llGetOwner(), TargetName + " is now OFFLINE.");
            }

            // Update status
            IsOnline = CurrentlyOnline;
        }
        else if (queryid == D_QueryID)
        {
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
                        TargetName = value;
                    } else if ( name == "CHECK_INTERVAL" ) {
                        CheckInterval = (float)value; 
                    }
                }
                NotecardLine++;
                D_QueryID = llGetNotecardLine( CONFIG_CARD, NotecardLine );
            }
        }
    }
}
