///////////////////////////////////////////////////////
//  Copyright (C) 2013-2014 Wizardry and Steamworks  //
//  Copyright (C) 2025      Truth & Beauty Lab       //
//  License: CC BY 2.0                               //
//  https://creativecommons.org/licenses/by/2.0/     //
///////////////////////////////////////////////////////
// 
// This component is responsible for sending a dialog menu to Corrade.
// For pressing menu items on dialogs, this script is not necessary and is here just as a test harness.
//
// Create a notecard named Config_Send:
// ####################### START CONFIGURATION ##################################
//  
// # All these settings must correspond to the settings in Corrade.ini.
//  
// # This is the UUID of the Corrade bot.
// corrade = "3ade3b74-378d-4fa1-88e6-96ea45d942bb"
//  
// # The name of the group - it can also be the UUID of the group.
// group = "My Group"
//  
// # The password for the group.
// password =  "mypassword"
//  
// # The menu items to send via llDialog to Corrade as a CSV list of strings.
// buttons = "AUTO"
//  
// ####################### END CONFIGURATION ###################################
// and configure it appropriately for your bot.
// 
// Copy the script below and drop it along with the Config_Send notecard in the same primitive.
//
// This is a menu selector for the Corrade bot that is capable of replying
// to dialog requests while supporting several nested levels of menus. You
// can find out more about the Corrade bot by following the URL: 
// http://was.fm/secondlife/scripted_agents/corrade
//
// The sit script works together with a "Config_Send" notecard that must 
// be placed in the same primitive as this script. The purpose of this 
// script is to demonstrate answering dialogs with Corrade and you are free 
// to use, change, and commercialize it under the CC BY 2.0  license at: 
// https://creativecommons.org/licenses/by/2.0
//
///////////////////////////////////////////////////////////////////////////
 
string wasKeyValueGet(string k, string data) {
    if(llStringLength(data) == 0) return "";
    if(llStringLength(k) == 0) return "";
    list a = llParseString2List(data, ["&", "="], []);
    integer i = llListFindList(a, [ k ]);
    if(i != -1) return llList2String(a, i+1);
    return "";
}
 
string wasKeyValueEncode(list data) {
    list k = llList2ListStrided(data, 0, -1, 2);
    list v = llList2ListStrided(llDeleteSubList(data, 0, 0), 0, -1, 2);
    data = [];
    do {
        data += llList2String(k, 0) + "=" + llList2String(v, 0);
        k = llDeleteSubList(k, 0, 0);
        v = llDeleteSubList(v, 0, 0);
    } while(llGetListLength(k) != 0);
    return llDumpList2String(data, "&");
}
 
integer wasListCountExclude(list input, list exclude) {
    if(llGetListLength(input) == 0) return 0;
    if(llListFindList(exclude, (list)llList2String(input, 0)) == -1) 
        return 1 + wasListCountExclude(llDeleteSubList(input, 0, 0), exclude);
    return wasListCountExclude(llDeleteSubList(input, 0, 0), exclude);
}
 
// corrade data
string CORRADE = "";
string GROUP = "";
string PASSWORD = "";
list BUTTONS = [];
 
// for notecard reading
integer line = 0;
 
// key-value data will be read into this list
list tuples = [];
 
default {
    state_entry() {
        // DEBUG
        llSetText("Dialog harness: touch to\n send dialog to Corrade.", <1,1,1>, 1.0);
        if(llGetInventoryType("Config_Send") != INVENTORY_NOTECARD) {
            llOwnerSay("Sorry, could not find a Config_Send inventory notecard.");
            return;
        }
        // DEBUG
        llOwnerSay("Reading Config_Send file...");
        llGetNotecardLine("Config_Send", line);
    }
    dataserver(key id, string data) {
        if(data == EOF) {
            // invariant, length(tuples) % 2 == 0
            if(llGetListLength(tuples) % 2 != 0) {
                llOwnerSay("Error in Config_Send notecard.");
                return;
            }
            CORRADE = llList2String(
                tuples,
                llListFindList(
                    tuples, 
                    [
                        "corrade"
                    ]
                )
            +1);
            if(CORRADE == "") {
                llOwnerSay("Error in Config_Send notecard: corrade");
                return;
            }
            GROUP = llList2String(
                tuples,
                llListFindList(
                    tuples, 
                    [
                        "group"
                    ]
                )
            +1);
            if(GROUP == "") {
                llOwnerSay("Error in Config_Send notecard: password");
                return;
            }
            PASSWORD = llList2String(
                tuples,
                llListFindList(
                    tuples, 
                    [
                        "password"
                    ]
                )
            +1);
            if(PASSWORD == "") {
                llOwnerSay("Error in Config_Send notecard: password");
                return;
            }
            BUTTONS = llCSV2List(
                llList2String(
                    tuples,
                    llListFindList(
                        tuples, 
                        [
                            "buttons"
                        ]
                    )
                +1)
            );
            if(llGetListLength(BUTTONS) == 0) {
                llOwnerSay("Error in Config_Send notecard: buttons");
                return;
            }
            // DEBUG
            llOwnerSay("Read Config_Send notecard...");
            state dialog;
        }
        if(data == "") jump continue;
        integer i = llSubStringIndex(data, "#");
        if(i != -1) data = llDeleteSubString(data, i, -1);
        list o = llParseString2List(data, ["="], []);
        // get rid of starting and ending quotes
        string k = llDumpList2String(
            llParseString2List(
                llStringTrim(
                    llList2String(
                        o, 
                        0
                    ), 
                STRING_TRIM), 
            ["\""], []
        ), "\"");
        string v = llDumpList2String(
            llParseString2List(
                llStringTrim(
                    llList2String(
                        o, 
                        1
                    ), 
                STRING_TRIM), 
            ["\""], []
        ), "\"");
        if(k == "" || v == "") jump continue;
        tuples += k;
        tuples += v;
@continue;
        llGetNotecardLine("Config_Send", ++line);
    }
    on_rez(integer num) {
        llResetScript();
    }
    changed(integer change) {
        if((change & CHANGED_INVENTORY) || (change & CHANGED_REGION_START)) {
            llResetScript();
        }
    }
}
 
state dialog {
    state_entry() {
        // DEBUG
        llOwnerSay("Touch to send dialog to Corrade...");
    }
    touch_start(integer num) {
        integer channel = -(integer)llFrand(100)-1;
        llListen(channel, "", (key)CORRADE, "");
        // DEBUG
        llOwnerSay("Sending dialog...");
        llDialog((key)CORRADE, "Please select from the options below: ", BUTTONS, channel);
    }
    listen(integer channel, string name, key id, string message) {
        llOwnerSay("Corrade pressed button: " + message);
    }
    on_rez(integer num) {
        llResetScript();
    }
    changed(integer change) {
        if((change & CHANGED_INVENTORY) || (change & CHANGED_REGION_START)) {
            llResetScript();
        }
    }
}
