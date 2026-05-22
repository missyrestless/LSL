// This script distinguishes between a quick tap and a hold longer than 2 seconds

default
{
    touch_start(integer total_number)
    {
        // Start the timer when the user clicks
        llResetTime();
    }

    touch_end(integer total_number)
    {
        // Check how long the user held the click
        float held_time = llGetTime();

        if (held_time <= 2.0)
        {
            // Execute this if the click was short
            llOwnerSay("You just tapped the object.");
        }
        else
        {
            // Execute this if the click was held
            llOwnerSay("You held the click for over a second!");
        }
    }
}
