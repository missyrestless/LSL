key gUserKey = "USER_KEY_HERE"; // Replace with the target avatar's UUID (User Key)
string gUserName = "Target Name"; // Optional: For display purposes

float gRepeatTime = 120.0; // Check every 120 seconds (2 minutes) to be server friendly

StatusUpdate() {
    // Request online status data for the specified user key
    llRequestAgentData(gUserKey, DATA_ONLINE);
}

default {
    state_entry() {
        llSetTimerEvent(gRepeatTime); // Set a timer to check periodically
        StatusUpdate(); // Initial check
        llSetText(gUserName + "\\nChecking status...", <1.0, 1.0, 1.0>, 1.0); // Initial hover text
    }

    timer() {
        StatusUpdate(); // Request status update when the timer fires
    }

    dataserver(key queryid, string data) {
        if (queryid == gUserKey) {
            string status = "Offline";
            vector color = <1.0, 0.0, 0.0>; // Red for offline

            if (data == "1") {
                status = "Online";
                color = <0.0, 1.0, 0.0>; // Green for online
            }

            llSetText(gUserName + "\\nStatus: " + status, color, 1.0); // Update hover text and color
        }
    }

    // Optional: Allows a touch to force an immediate update
    touch_start(integer num) {
        StatusUpdate();
    }
}
