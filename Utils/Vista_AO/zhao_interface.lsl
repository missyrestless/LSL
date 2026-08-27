// ZHAO AO INTERFACE
//
// Written 27-Aug-2026 by Missy Restless <missyrestless@gmail.com>
//
// Drop this script into a ZHAO based AO to enable remote command controls
// Use the accompanying gestures to issue commands to the ZHAO AO
//
// For example, once the gestures are activated, to enable the AO,
// the owner can type /aoon in local chat. To disable the AO, owner
// can type /aooff in local chat.
//
// The Vista animation overriders in Second Life are based on the ZHAO-II engine
// (by Ziggy Puff, mod by Marcus Gray, Johann Ehrler and Moeka Kohime) and the
// Vista AOs that were tested contain the ZHAO-II-core MGJEmod 1.1.9 script.
//
// Even though the Vista animation creator does not disclose the GPLv2 source,
// the header of the ZHAO-II-core MGJEmod 1.1.9 script mentions the following:
//
// ZHAO-II-core - Ziggy Puff, 07/07
//
/////////////////////////////////////////////////////////////////////////////////////////////////////
// Main engine script - receives link messages from any interface script. Handles the core AO work
//
// Interface definition: The following link_message commands are handled by this script. All of 
// these are sent in the string field. All other fields are ignored
//
// ZHAO_RESET                          Reset script
// ZHAO_LOAD|<notecardName>            Load specified notecard
// ZHAO_NEXTSTAND                      Switch to next stand
// ZHAO_STANDTIME|<time>               Time between stands. Specified in seconds, expects an integer.
//                                     0 turns it off
// ZHAO_AOON                           AO On
// ZHAO_AOOFF                          AO Off
// ZHAO_SITON                          Sit On
// ZHAO_SITOFF                         Sit Off
// ZHAO_RANDOMSTANDS                   Stands cycle randomly
// ZHAO_SEQUENTIALSTANDS               Stands cycle sequentially
// ZHAO_SETTINGS                       Prints status
// ZHAO_SITS                           Select a sit
// ZHAO_GROUNDSITS                     Select a ground sit
// ZHAO_WALKS                          Select a walk
//
// ZHAO_SITANYWHERE_ON                 Sit Anywhere mod On 
// ZHAO_SITANYWHERE_OFF                Sit Anywhere mod Off 
//
// ZHAO_TYPE_ON                        Typing AO On 
// ZHAO_TYPE_OFF                       Typing AO Off 
//
// ZHAO_TYPEKILL_ON                    Typing Killer On 
// ZHAO_TYPEKILL_OFF                   Typing Killer Off 
//
// So, to send a command to the ZHAO-II engine, send a linked message:
//
//   llMessageLinked(LINK_SET, 0, "ZHAO_AOON", NULL_KEY);

default
{
    state_entry() {
        llListen(935840, "", llGetOwner(), "");
    }
 
    listen(integer channel, string name, key id, string message) {
        string cmd = llToLower(message);
        if (cmd == "aoon") {
            llMessageLinked(LINK_SET, 0, "ZHAO_AOON", NULL_KEY);
            return;
        } else if (cmd == "aooff") {
            llMessageLinked(LINK_SET, 0, "ZHAO_AOOFF", NULL_KEY);
            return;
        } else if (cmd == "aorandomstands") {
            llMessageLinked(LINK_SET, 0, "ZHAO_RANDOMSTANDS", NULL_KEY);
            return;
        } else if (cmd == "aosequentialstands") {
            llMessageLinked(LINK_SET, 0, "ZHAO_SEQUENTIALSTANDS", NULL_KEY);
            return;
        } else if (cmd == "aositon") {
            llMessageLinked(LINK_SET, 0, "ZHAO_SITON", NULL_KEY);
            return;
        } else if (cmd == "aositoff") {
            llMessageLinked(LINK_SET, 0, "ZHAO_SITOFF", NULL_KEY);
            return;
        } else if (cmd == "aonextstand") {
            llMessageLinked(LINK_SET, 0, "ZHAO_NEXTSTAND", NULL_KEY);
            return;
        } else if (cmd == "aoreset") {
            llMessageLinked(LINK_SET, 0, "ZHAO_RESET", NULL_KEY);
            return;
        } else if (cmd == "aosettings") {
            llMessageLinked(LINK_SET, 0, "ZHAO_SETTINGS", NULL_KEY);
            return;
        } else if (cmd == "aosits") {
            llMessageLinked(LINK_SET, 0, "ZHAO_SITS", NULL_KEY);
            return;
        } else if (cmd == "aogroundsits") {
            llMessageLinked(LINK_SET, 0, "ZHAO_GROUNDSITS", NULL_KEY);
            return;
        } else if (cmd == "aowalks") {
            llMessageLinked(LINK_SET, 0, "ZHAO_WALKS", NULL_KEY);
            return;
        } else if (cmd == "aositanywhere_on") {
            llMessageLinked(LINK_SET, 0, "ZHAO_SITANYWHERE_ON", NULL_KEY);
            return;
        } else if (cmd == "aositanywhere_off") {
            llMessageLinked(LINK_SET, 0, "ZHAO_SITANYWHERE_OFF", NULL_KEY);
            return;
        } else if (cmd == "aotype_on") {
            llMessageLinked(LINK_SET, 0, "ZHAO_TYPE_ON", NULL_KEY);
            return;
        } else if (cmd == "aotype_off") {
            llMessageLinked(LINK_SET, 0, "ZHAO_TYPE_OFF", NULL_KEY);
            return;
        } else if (cmd == "aotypekill_on") {
            llMessageLinked(LINK_SET, 0, "ZHAO_TYPEKILL_ON", NULL_KEY);
            return;
        } else if (cmd == "aotypekill_off") {
            llMessageLinked(LINK_SET, 0, "ZHAO_TYPEKILL_OFF", NULL_KEY);
            return;
        } else if (llSubStringIndex(cmd, "aoload ") == 0) {
            list notename = llParseString2List(cmd, [" "], []);
            // Delete the very first element (index 0) from the list
            notename = llDeleteSubList(notename, 0, 0);
            // Join the remaining words back together with a space
            llMessageLinked(LINK_SET, 0, "ZHAO_LOAD|" + llDumpList2String(notename, " "), NULL_KEY);
            return;
        } else if (cmd == "aostandtime") {
            list time = llParseString2List(cmd, [" "], []);
            // Delete the very first element (index 0) from the list
            time = llDeleteSubList(time, 0, 0);
            // Join the remaining words back together with a space
            llMessageLinked(LINK_SET, 0, "ZHAO_STANDTIME|" + llDumpList2String(time, " "), NULL_KEY);
            return;
        }
    }
 
    on_rez(integer num) {
        llResetScript();
    }
 
    changed(integer channel) {
        llResetScript();
    }
}
