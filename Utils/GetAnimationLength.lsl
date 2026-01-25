default
{
    state_entry()
    {
        llSay(0, "Starting animation...");
        llStartAnimation("your_animation_name"); // Replace with your anim name
        llSetTimerEvent(0.1); // Check every 0.1 seconds
    }

    timer()
    {
        if (llGetAnimationList(llGetOwner()) == "") // If no animations are playing
        {
            llSay(0, "Animation finished!");
            llSetTimerEvent(0); // Stop timer
        }
    }
    // Or use the animation_end event for more precision if available/applicable
    // animation_end(key id) { llSay(0, "Animation ended!"); }
}
