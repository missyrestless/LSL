float cloakSpeed = 0.1;

default
{
    touch_end(integer total_number)
    {
        float alpha = 1.0;
        while(alpha > 0.0)
        {
            alpha -= 0.1;
            llSetAlpha(alpha, ALL_SIDES);
            llSleep(cloakSpeed);
        }
        state cloaked;
    }
}

state cloaked
{
    touch_end(integer total_number)
    {
        float alpha;
        while (alpha < 1.0)
        {
            alpha += 0.1;
            llSetAlpha(alpha, ALL_SIDES);
            llSleep(cloakSpeed);
        }
        state default;
    }
}