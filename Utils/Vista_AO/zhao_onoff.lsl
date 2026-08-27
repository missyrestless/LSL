// Enable the owner of the AO to type on local chat:
//
//   /7331 on
//
// to enable the AO, and:
//
//   /7331 off
//
// to disable the AO

default
{
    state_entry()
    {
        llListen(
            7331, 
            "", 
            llGetOwner(), 
            ""
        );
    }
 
    listen(integer channel, string name, key id, string text) {
        if(text == "on") {
            llMessageLinked(LINK_SET, 0, "ZHAO_AOON", NULL_KEY);
            return;
        }
 
        if(text == "off") {
            llMessageLinked(LINK_SET, 0, "ZHAO_AOOFF", NULL_KEY);
            return;
        }
 
        // More, if you so desire...
    }
 
    on_rez(integer num) {
        llResetScript();
    }
 
    changed(integer channel) {
        llResetScript();
    }
}
