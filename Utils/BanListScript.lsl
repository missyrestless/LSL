// This script is intended for parcel bans.
// For estate bans, an Estate Manager must use estate tools.
//
// Create a new notecard in the contents and name it Ban_List.
// Edit the Ban_List notecard and paste your list of avatar UUIDs, one UUID to a line.
// Right-click and "Touch" the object.
// Say "ban" in local chat (within listening range of the object) to trigger the import. 

key query_id;
string notecard_name = "Ban_List"; // Name of your notecard
integer line_number = 0;           // Start from line 0
list ban_list;                    // To store the read UUIDs

default {

    state_entry() {
        llListen(0, "", llGetOwner(), "");
        llOwnerSay("Ban Bot is active. Drop a notecard named 'Ban_List' and say 'ban' to process.");
    }

    listen(integer channel, string name, key id, string message)
    {
        if (llToLower(message) == "ban")
        {
            llOwnerSay("Reading notecard and processing bans...");
            query_id = llGetNotecardLine(notecard_name, line_number);
        }
    }

    dataserver(key id, string data) {
        if (id == query_id) {
            if (data == EOF) {
                // End of file reached, all UUIDs read
                llOwnerSay("Finished reading UUIDs.");
                integer num_bans = llGetListLength(ban_list);
                integer i;

                for (i = 0; i < num_bans; i++)
                {
                    key avatar_to_ban = (key)llList2String(ban_list, i);
                    llAddToLandBanList(avatar_to_ban, 0.0);
                    llOwnerSay("Banned: " + (string)avatar_to_ban);
                    llSleep(1.0); // Sleep to prevent script time-outs
                }
            } else {
                // Add the current line (UUID) to the list
                ban_list += data;
                // Request the next line
                line_number++;
                query_id = llGetNotecardLine(notecard_name, line_number);
            }
        }
    }
}
