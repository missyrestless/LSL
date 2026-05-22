// The Experience Key-Value Store (KVP) allows you to store and retrieve data tied to a
// specific Second Life Experience rather than a single prim. It holds up to 128 MiB of data
// across the grid, using asynchronous LSL functions that communicate via dataserver events.
//
// Prerequisites
//
//   Account Type: You must be a Premium or Premium Plus member to acquire an Experience key.
//
//   Acquire an Experience: In the official Second Life Viewer, go to Me > Experiences > Owned
//   and click Acquire an Experience.
//
//   Enable Experience in Scripts: Your scripted object must be associated with your experience.
//   Open your script in an experience-enabled viewer, check the Use Experience box, and select
//   your Experience from the list.
//
// Required LSL Functions
//
//   Write Data: Use llCreateKeyValue to add new data and llUpdateKeyValue to change existing data.
//
//   Read Data: Use llReadKeyValue(string key) to retrieve a value.
//
//   Delete Data: Use llDeleteKeyValue(string key).
//
// Basic KVP Reading & Writing Example
//
// Since KVP interactions are asynchronous, the script fires a handle and waits for a dataserver
// event to process success or failure.

string myKey = "player_score_12345";
string myValue = "100";

default
{
    touch_start(integer total_number)
    {
        // 1. Write the key-value pair to the experience
        llCreateKeyValue(myKey, myValue);
        llOwnerSay("Writing KVP...");
    }

    dataserver(key queryid, string data)
    {
        // 2. Process the callback from the dataserver
        list results = llParseString2List(data, [","], []);
        integer success = (integer)llList2String(results, 0);

        if (success)
        {
            llOwnerSay("Success! Stored the value.");
            
            // 3. Read the value back
            llReadKeyValue(myKey);
        }
        else
        {
            string errorMsg = llGetExperienceErrorMessage((integer)llList2String(results, 1));
            llOwnerSay("Failed. Error: " + errorMsg);
        }
    }
}
