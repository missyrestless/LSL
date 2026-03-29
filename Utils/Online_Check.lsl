key userKey = "UUID_OF_USER"; // Replace with the user's UUID
key requestID;

default
{
    state_entry()
    {
        // Start checking when script starts or on touch
        requestID = llRequestAgentData(userKey, DATA_ONLINE);
    }

    touch_start(integer total_number)
    {
        requestID = llRequestAgentData(userKey, DATA_ONLINE);
    }

    dataserver(key queryid, string data)
    {
        if (queryid == requestID)
        {
            if (data == "1")
            {
                llOwnerSay("User is online.");
            }
            else
            {
                llOwnerSay("User is offline.");
            }
        }
    }
}
