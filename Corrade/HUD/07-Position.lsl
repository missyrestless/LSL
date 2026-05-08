///////////////////////////////////////////////////////////////////////////
//  Copyright (C) Wizardry and Steamworks 2016 - License: GNU GPLv3      //
///////////////////////////////////////////////////////////////////////////

default {
    state_entry() {
        llPassTouches(2);
    }
    link_message(integer sender, integer num, string str, key id)
    {
        if(sender != 1) return;
        if(str == "deploy") {
            llSetAlpha(1, ALL_SIDES);
            llSetPos(<0, -0.05881, 0.05811>);
            return;
        }
        if(str == "retract") {
            llSetPos(ZERO_VECTOR);
            llSetAlpha(0, ALL_SIDES);
        }
    }
}
