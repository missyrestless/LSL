// --- CONFIGURATION ---
// Replace with the UUID of the avatar to track
key TargetAvatar = "YOUR_TARGET_UUID"; 
// How often to check in seconds (60s minimum recommended)
float CheckInterval = 600.0; 
// ---------------------

key AgentDataRequestID;
integer IsOnline = FALSE; // Assume offline initially

default
{
    state_entry()
    {
        // Start monitoring immediately
        llSetTimerEvent(CheckInterval);
        // Do an initial check immediately
        AgentDataRequestID = llRequestAgentData(TargetAvatar, DATA_ONLINE);
    }

    timer()
    {
        // Periodically check status
        AgentDataRequestID = llRequestAgentData(TargetAvatar, DATA_ONLINE);
    }

    dataserver(key queryid, string data)
    {
        if (queryid == AgentDataRequestID)
        {
            integer CurrentlyOnline = (integer)data;

            // If they just came online and were previously offline
            if (CurrentlyOnline && !IsOnline)
            {
                llInstantMessage(llGetOwner(), "Target user is now ONLINE.");
            }
            // Optional: Notify when they go offline
            // else if (!CurrentlyOnline && IsOnline)
            // {
            //     llInstantMessage(llGetOwner(), "Target user is now OFFLINE.");
            // }

            // Update status
            IsOnline = CurrentlyOnline;
        }
    }
}
