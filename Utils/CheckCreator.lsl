// CheckCreator - check the creator name against a list of creators who have
//     stated their animations were pirated. Remove any animations by these
//     creators. This script is intended as an aid to content creators who are
//     packaging full-perm animations they have acquired for resale but who
//     wish to avoid redistribution of animations which are allegedly pirated.
//
// Written by Missy Restless (missyrestless at gmail dot com)
// Modified 26-Dec-2011 - incorporate suggestion from PeterCanessa Oh to count
//     backwards in while loop to improve efficiency
//
// Usage: Drop this script into the Contents of a prim containing the
//        animations you wish to distribute/resell. Close the edit window
//        and touch the prim when prompted. The script will chat the
//        names of animations it is deleting as well as the creator's
//        name then the script will delete itself from the prim.
//
// License: You are free to use, modify, copy, and redistribute this script.
//          Please return relevant/useful modifications to Missy Restless.
//
// Info:
//     http://wiki.secondlife.com/w/index.php?title=62_Animation_MLP_Set
//     http://wiki.secondlife.com/wiki/Stroker_Serpentine_Sexgen_Animation_Set
//     http://bit.ly/vlOPKp
//     http://tinyurl.com/5wk3mr2
//

integer numkeys;
integer keynum = 0;
string creator_name = "";
string creator_key;
key name_query;
list key_name_pairs = [];
list creator_keys = ["b85e0cdf-4fb2-4383-8b0f-7ff15d01c427",
                     "16c565f2-b5a2-4791-bf8a-24e4599abc28",
                     "02409c8a-508c-4c68-8537-6c4166d2841b",
                     "1f3f9aea-15cd-4a6d-85c2-2e724c8c045c",
                     "32101244-c1f2-45a7-9a1f-96dc463068d8"];
// Uncomment this key and add it to the above list if you also
// wish to remove animations created by Stroker Serpentine
// "368f6798-4d43-4a01-91b0-f6259e279170"
 
default
{
    state_entry()
    {
        if (llGetInventoryType("CheckCreator Package Anchor") == -1) {
            numkeys = llGetListLength(creator_keys);
            // First we walk through the list of keys and get their names
            state getnames;
        }
    }
}

state getnames
{
    state_entry()
    {
        if (keynum < numkeys) {
            creator_key = llList2String(creator_keys, keynum);
            name_query = llRequestAgentData((key)creator_key, DATA_NAME);
        }
        else
            state doit;
    }

    dataserver(key queryid, string data)
    {
        if (name_query == queryid)
        {
            creator_name = data;
            key_name_pairs += [creator_key, creator_name];
            keynum++;
            if (keynum == numkeys)
                state doit;
            else
                state default;
        }
    }
}

state doit
{
    state_entry()
    {
        llOwnerSay("CAUTION: Once removed the items are gone forever, they do not return to your inventory. Be careful with no copy items.\n");
        llOwnerSay("\nTouch the prim to begin checking and removing potentially pirated animations.");
    }

    touch_start(integer num_detected)
    {
        key         Creator = "";
        integer     i = 0;
        integer     j = 0;
        integer     index;
        string      name = "";

        integer numanims = llGetInventoryNumber(INVENTORY_ANIMATION);
        for(i=0; i<num_detected; i++) {
            if (llGetOwner() == llDetectedKey(i)) { // Only owner can do this
                i = num_detected; // Ignore multiple touches
                llOwnerSay("\nChecking " + (string)numanims +
                           " animations in prim inventory");
                while (numanims--) {
                    name = llGetInventoryName(INVENTORY_ANIMATION, numanims);
                    Creator = llGetInventoryCreator(name);
                    creator_name = "";
                    index = llListFindList(key_name_pairs, [(string)Creator]);
                    if (index != -1) {
                        creator_name = llList2String(key_name_pairs, index + 1);
                        llOwnerSay("Removing " + name +
                                   " created by " + creator_name);
                        llRemoveInventory(name);
                        llSleep(0.2); // Slow down a bit to avoid errors
                    }
                }
            }
            llSleep(0.4); // Allow inventory to refresh
            numanims = llGetInventoryNumber(INVENTORY_ANIMATION);
            llOwnerSay("\nExiting. " + (string)numanims +
                       " animations left in prim inventory");
            llRemoveInventory(llGetScriptName());
            return;
        }
    }
}
