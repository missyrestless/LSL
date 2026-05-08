// This is a basic example and may require advanced LSL knowledge.
// It is intended for parcel bans. For estate bans, an Estate Manager must use estate tools.
//
// Create a new notecard in the contents and name it Ban_List.
// Edit the Ban_List notecard and paste your list of avatar UUIDs, separated by commas, on a single line.
// Recompile the script and take a copy of the object.
// Right-click and "Touch" the object.
// Say "ban" in local chat (within listening range of the object) to trigger the import. 

string notecard_name = "Ban_List";

default
{
    state_entry()
    {
        llListen(0, "", llGetOwner(), "");
        llOwnerSay("Ban Bot is active. Drop a notecard named 'Ban_List' and say 'ban' to process.");
    }

    listen(integer channel, string name, key id, string message)
    {
        if (llToLower(message) == "ban")
        {
            llOwnerSay("Reading notecard and processing bans...");
            llGetNotecardLine(notecard_name, 0);
        }
    }

    dataserver(key queryid, string data)
    {
        if (data == EOF)
        {
            llOwnerSay("Done processing ban list.");
            return;
        }

        list ban_list = llCSV2List(data);
        integer num_bans = llGetListLength(ban_list);
        integer i;

        for (i = 0; i < num_bans; i++)
        {
            key avatar_to_ban = (key)llList2String(ban_list, i);
            llAddToLandBanList(avatar_to_ban, 0.0); // 0.0 hours for an indefinite ban
            llOwnerSay("Banned: " + (string)avatar_to_ban);
            llSleep(1.0); // Sleep to prevent script time-outs
        }
    }
}
