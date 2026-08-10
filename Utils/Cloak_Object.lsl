// Touch by owner of object toggles Face 0 transparency
// Face 5 is transparent when Face 0 is transparent
// Face 5 is dimmed slightly when Face 0 is visible

float cloakSpeed = 0.1;

default
{
    touch_end(integer total_number)
    {
        if (llDetectedKey(0) == llGetOwner()) {
            float alpha = 1.0;
            while(alpha > 0.0) {
                alpha -= 0.1;
                llSetAlpha(alpha, 0);
                llSleep(cloakSpeed);
            }
            llSetAlpha(0.0, 5);
            state cloaked;
        }
    }
}

state cloaked
{
    touch_end(integer total_number)
    {
        if (llDetectedKey(0) == llGetOwner()) {
            float alpha;
            while (alpha < 1.0) {
                alpha += 0.1;
                llSetAlpha(alpha, 0);
                llSleep(cloakSpeed);
            }
            llSetAlpha(0.0075, 5);
            state default;
        }
    }
}
