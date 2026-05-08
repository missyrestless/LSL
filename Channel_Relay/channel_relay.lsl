////////////////////////////////////////////////////////////////
// Channel Relay - relay messages on a specified channel to   //
//                 instant messages to a configured recipient //
////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////
// Copyright (c) 2026 Truth & Beauty Lab             //
// Author:  Missy Restless <missyrestless@gmail.com> //
// Created: 28-Mar-2026                              //
// License: MIT                                      //
///////////////////////////////////////////////////////
string botName = "";
// The channel number to listen on and relay
integer listenChannel = -7742001;
// Set DEBUG to 1 to enable debug output
integer DEBUG = 0;

integer listenEnabled = FALSE;
integer listen_handle;
key botKey = NULL_KEY;

// Configuration Notecard
string CONFIG_CARD = "ChannelRelayConf";
integer NotecardLine;
integer NotecardDone = 0;
key QueryID;

bot_name_not_set() {
    llOwnerSay("ERROR: LB_BOT_NAME not set.");
    llOwnerSay("Edit the ChannelRelayConf notecard to set your LifeBots Bot Name.");
}

default {
    state_entry()
    {
        llOwnerSay("Starting up Channel Relay script...");
        if (llGetInventoryType(CONFIG_CARD) == INVENTORY_NOTECARD) {
            NotecardLine = 0;
            QueryID = llGetNotecardLine(CONFIG_CARD, NotecardLine);
        } else {
            llOwnerSay("ERROR: " + CONFIG_CARD + " notecard not found!");
        }
    }

    on_rez(integer param)
    {
         llResetScript();
    }

    changed(integer change)
    {
         if (change & (CHANGED_OWNER | CHANGED_INVENTORY))
         {
             llResetScript();
         }
    }

    dataserver( key queryid, string data )
    {
        list temp;
        string name;
        string value;
        if ( queryid == QueryID ) {
            if ((NotecardDone == 0) && (data != EOF)) {
                if (data == "END_SETTINGS") {
                    NotecardDone = 1;
                    if ((botName == "") || (botName == "Bot Name")) {
                        bot_name_not_set();
                    } else {
                        // Request the key from the bot name
                        if (botKey == NULL_KEY) {
                            botKey = llRequestUserKey(botName);
                        }
                    }
                } else if ( llGetSubString(data, 0, 0) != "#" && llStringTrim(data, STRING_TRIM) != "" ) {
                    temp = llParseString2List(data, ["="], []);
                    name = llStringTrim(llList2String(temp, 0), STRING_TRIM);
                    value = llStringTrim(llList2String(temp, 1), STRING_TRIM);
                    if ( value == "TRUE" ) value = "1";
                    if ( value == "FALSE" ) value = "0";
                    if ( name == "LB_BOT_NAME" ) {
                        if (DEBUG == 1) {
                          llSay(DEBUG_CHANNEL, "Setting Bot Name to " + value);
                        }
                        botName = value;
                    } else if ( name == "LISTEN_CHANNEL" ) {
                        listenChannel = (integer)value;
                    } else if ( name == "DEBUG" ) {
                        DEBUG = (integer)value;
                    }
                }
                NotecardLine++;
                QueryID = llGetNotecardLine( CONFIG_CARD, NotecardLine );
            } else {
                NotecardLine = 0;
            }
        } else {
            if (queryid == botKey) {
                if (data == NULL_KEY) {
                    llOwnerSay(botName + " not found or offline.");
                } else {
                    llOwnerSay(botName + " ready to receive IMs");
                    if (listenEnabled) {
                        llOwnerSay("Touch me to disable relay on channel " + (string)listenChannel);
                    } else {
                        llOwnerSay("Touch me to enable relay on channel " + (string)listenChannel);
                    }
                }
            }
        }
    }

    touch_start(integer num) {
        if (llDetectedKey(0) == llGetOwner()) {
            if (listenEnabled) {
                llOwnerSay("Touch detected. Removing listen handle from channel " + (string)listenChannel);
                llListenRemove(listen_handle);
                listenEnabled = FALSE;
            } else {
                llOwnerSay("Touch detected. Send test messages on channel " + (string)listenChannel);
                listen_handle = llListen(listenChannel, "", "", "");
                listenEnabled = TRUE;
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == listenChannel) {
            if (DEBUG == 1) {
                llOwnerSay("Script heard channel message: " + message);
            }
            // Send the message to the bot
            if (botKey == NULL_KEY) {
                if (DEBUG == 1) {
                    llOwnerSay("NULL bot key, message not sent");
                }
                botKey = llRequestUserKey(botName);
            } else {
                if (DEBUG == 1) {
                    llOwnerSay("Sending message to bot");
                }
                llInstantMessage(botKey, message);
            }
        }
    }
}
