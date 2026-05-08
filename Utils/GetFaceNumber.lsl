
say(string message)
{
    llSay(PUBLIC_CHANNEL, message);
}

default
{
    touch_start(integer num_detected)
    {
        integer face = llDetectedTouchFace(0);

        if (face == TOUCH_INVALID_FACE)
            say("The touched face could not be determined");
        else
            say("You touched face number " + (string) face);
    }
}
