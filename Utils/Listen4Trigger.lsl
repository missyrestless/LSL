default
{
    state_entry()
    {
        // Listen for anything said on channel 0 (public chat) by any avatar
        llListen(0, "", NULL_KEY, "");
    }

    listen(integer channel, string name, key id, string message)
    {
        // Convert the message to lowercase so your trigger is not case-sensitive
        string lower_msg = llToLower(message);
        
        // Check if your trigger word exists in the sentence
        if (llSubStringIndex(lower_msg, "triggerword") != -1)
        {
            // Action to take when the word is detected
            llOwnerSay("I heard you say the word!");
        }
    }
}
