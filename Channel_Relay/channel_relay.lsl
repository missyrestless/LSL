// Customize the bot name, channel, and debug
//
//////// CUSTOMIZE THESE: BOT NAME, CHANNEL, AND DEBUG           //
string botName = "Bot Name";                                     // REQUIRED
// The channel number to listen on and relay                     //
integer LISTEN_CHANNEL = -7742001;                               // OPTIONAL
// Set DEBUG to 1 to enable debug output                         //
integer DEBUG = 0;                                               // OPTIONAL
//////// END CUSTOMIZE, NO CHANGES BEYOND HERE ////////////////////

integer listenEnabled = FALSE;
integer listen_handle;
key botKey = NULL_KEY;

default {
    state_entry() {
        llOwnerSay("Starting up Channel Relay script...");
        // Request the key from the bot name
        if (botKey == NULL_KEY) {
            botKey = llRequestUserKey(botName);
        }
    }

    dataserver(key queryid, string data)
    {
        if (queryid == botKey) {
            if (data == NULL_KEY) {
                llOwnerSay(botName + " not found or offline.");
            } else {
                llOwnerSay(botName + " ready to receive IMs");
                if (listenEnabled) {
                    llOwnerSay("Touch me to disable relay on channel " + (string)LISTEN_CHANNEL);
                } else {
                    llOwnerSay("Touch me to enable relay on channel " + (string)LISTEN_CHANNEL);
                }
            }
        }
    }

    touch_start(integer num) {
        if (llDetectedKey(0) == llGetOwner()) {
            if (listenEnabled) {
                llOwnerSay("Touch detected. Removing listen handle from channel " + (string)LISTEN_CHANNEL);
                llListenRemove(listen_handle);
                listenEnabled = FALSE;
            } else {
                llOwnerSay("Touch detected. Send test messages on channel " + (string)LISTEN_CHANNEL);
                listen_handle = llListen(LISTEN_CHANNEL, "", "", "");
                listenEnabled = TRUE;
            }
        }
    }
    
    listen(integer channel, string name, key id, string message) {
        if (channel == LISTEN_CHANNEL) {
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
