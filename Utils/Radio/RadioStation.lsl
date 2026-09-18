//FC's Parcel Music Manager

//version 5.0 for Mesh SoundMate (but works with every arbitrary prim)

//by Franklyn Constantine, 2009-2021 all rights reserved.

//this radio set reads music station URLs from a notecard and sets the parcel music appropriately.

// written under use of free LSL examples


// Terms of use:
// this program must not be sold alone, it may be copied or resold as a part of a new product, 
// as long as it is not the main purpose of the new creation.

// example: put it into a self made radio, or any other unique own creation and sell it - it's OK!
//          put it in a freebie, or any other 3rd party stuff and sell it - this is NOT OK!


// if reused, Franklyn Constantine  shall be mentioned in the credits. 


string VERSION = "5.1.2"; //the current version 

integer is_SoundMate = FALSE;  // determines if itn is a soundmate or not

integer RELAY_CHANNEL = 23227; //change this in both the radio AND the relay if required

float freeURL_reset_time = 10800.0; // edit this to choose any wanted reset time to last station

integer CHANNEL = 6583; //the base channel
integer channel; //the actual channel


integer FACE_LED=3; //this is only needed to light the LED of my soundmate radio; leave it inactive for any other use (except your build has a face which shall turn red/ green.

integer UPDATE_PIN = 17433; //PINs the hosting Prim, allowing future updates

list genre = []; //categories of stations, added with 5.0
list station_list = [];
list menu_list = [];

list menu_page = []; // a subset of the menu list
list station_page = []; // the same for the station URLs

string now_playing;

integer selected_index;
string current_station;
string freeURL_last_station;


integer is_twinkle = FALSE; //twinkle extension
integer is_grouponly=FALSE; //Group access rights
integer is_owneronly=FALSE; //Owner access right

integer is_own_land = TRUE; //radio and land should be owned by the same (parcel default)

integer genre_changed = FALSE; //to assist recall of the station list after a genre change

key toucher; // the avatar who touched the hosting prim
key admin = NULL_KEY; // the one who may select options, as defined in the 'admin' notecard

integer no_of_stations;

integer no_of_pages;

integer current_page = 0; // the current menu page (a part of the index number)

integer l_handle; // the listener handle for radio stations selection

string stations_card; // the name of the genre to play , represented by a notecard

// Read out a complete notecard from the object's inventory.
string gName;    // name of a notecard in the object's inventory
integer gLine = 0;        // current line number
key gQueryID; // id used to identify dataserver queries

buildMenu(integer page)
{
    integer page_index;
    
    menu_page = llList2List(menu_list, (page*7), (page*7)+6); //extract a portion of the stations
    
    station_page = llList2List(station_list, (page*7), (page*8)+6); // dito, for the URL indices
    
    //add some buttons which appear on any menu page
    menu_page += ["OPTIONS"]; // channel and access
    // comment out end
                
    menu_page += ["FREE URL"]; // add any custom URL
                
    //menu_page += ["Off"]; // add an "off" button (enters a 'void' into the parcel URL field) //removed for a genre button
    
    menu_page += ["GENRE"]; // add a "Genre" button for the various niche notecards (added with 5.0)
    menu_page += ["NEXT"]; 
    
    menu_page += ["BACK"];
    
}

//** added with 4.0 - multi system stream channel identification **
string GetCurrentChannel() // gets and identifies the current played parcel sound URL
{
    string current_url = llGetParcelMusicURL(); //read the parcel stream URL
    
    integer found_url_index;
    string current_stream; 
    
  
    found_url_index = llListFindList( station_list, [current_url] ); // compare the parcel stream with radio entries (stations)
    
    if (found_url_index < 0) // if there is no match
    {
      current_stream  = "<not identified>"; //report this back
    }
    else
    {
        current_stream = llList2String(menu_list, found_url_index); //otherwise lookup for the station name (same index!)
    }
    
    return current_stream; // tell the result
    
 }

default
{
    state_entry()
    {
        llSay(0, "FC's Web Radio Tuner Version" + VERSION);
        
        llSetRemoteScriptAccessPin(UPDATE_PIN);
        
        channel = CHANNEL;
        
        stations_card = llGetInventoryName(INVENTORY_NOTECARD, 1);
        
        state read_admin;
    }

    
}

state radio
{
    state_entry()
    {  
        vector this_land = llGetPos();
        // changes with 4.2 - parcel relay enabled
        
        //checking if the radio operates on own land, or needs a relay
        if (llGetOwner() == llGetLandOwnerAt(this_land)) is_own_land = TRUE;
        else is_own_land = FALSE;
        
        //llSay(0, "Debug - state radio reached.");
        
        if(genre_changed)
        {
            
            l_handle = llListen(channel, "", NULL_KEY, "");
            
            buildMenu(0);
            
            genre_changed = FALSE; //reset the genre changed notifier
        
            llDialog(toucher, "Currently playing " + now_playing +  ".\nSelect a radio station:", menu_page, channel);
            
            
                
            return; 
        }
    }
        
    
    touch_start(integer total_number)
    {
        
        toucher = llDetectedKey(0);
        
        if (toucher != admin)
        {
        
            if (is_grouponly && llSameGroup(toucher) == FALSE)
            {
                llInstantMessage(toucher, "Sorry, operation is only allowed for group members.");
            
                return;
            }
            
            if (is_owneronly && toucher != admin)
            {
                llInstantMessage(toucher, "Sorry, operation is only allowed for the owner/administrator of this radio set.");
            
                return;
            }
            
            
        }
        
        l_handle = llListen(channel, "", NULL_KEY, "");
        
        buildMenu(current_page);
        
        now_playing = GetCurrentChannel();
        
        llDialog(toucher, "Currently playing "  + now_playing + ", GENRE: " + stations_card  + ".\nSelect a radio station:", menu_page, channel);
       llSay(0, "<click>");

    }
    
    listen(integer channel, string name, key id, string selected)
    {
        //llOwnerSay("debug - entered non-twinkle section");
        if (selected == "GENRE")
        {
            state select_genre;
        }
            
        if (selected == "NEXT")
        {
            current_page++;
                
            if (current_page > no_of_pages-1) current_page = 0; //reroll
                
            //llSay(0, "debug - current page = " + (string)current_page);
                
            buildMenu(current_page);
        
            llDialog(toucher, "Currently playing " + now_playing + ", GENRE: " + stations_card + ".\nSelect a radio station:", menu_page, channel);
                
            return; 
        }
            
        if (selected == "BACK")
        {
            //llSay(0, "debug - current page = " + (string)current_page);
                
            if (current_page == 0) current_page = no_of_pages;
            else current_page--;
                
            buildMenu(current_page);
        
            llDialog(toucher, "Currently playing " + now_playing + ", GENRE: " + stations_card +  ".\nSelect a radio station:", menu_page, channel);
                
            return; 
        }
            
        if (selected == "FREE URL") 
        {
            state free_url;
                
            return;
        }
        
        if (selected == "OPTIONS") 
        {  
            if (toucher == admin || toucher == llGetOwner())
            {
                state options;  
                
            }
            else
            {
                llSay(0, "Options are only available for the owner/administrator of this radio set.");
            }
            
            return;
        }
        
            
        now_playing = selected;
        
        selected_index = llListFindList( menu_page, [selected] );
        
        //llOwnerSay("Debug - index for " + selected + " is " + (string)selected_index);
        
        current_station = llList2String(station_page, selected_index);
        
        //llOwnerSay("Debug - selected station is " + current_station);
        
            
        if (is_own_land) llSetParcelMusicURL(current_station);
        else llSay(RELAY_CHANNEL, current_station);
        
        if (llToLower(selected) == "off") llSay(0, "Switching off...");
        else  llSay(0, "FM station was changed to "+ selected);
        
        //*** ON/ OFF LED (new for Mesh Radio, leave it off for any other build, it will turn a face green or red, and you may not want that?!)
        if (is_SoundMate)  // checks the configuration variable: is the radio a SoundMate or not?
        { // if yes, enable the busy LED
            if (llToLower(selected) == "off")
            {
                llSetColor(<135, 0, 0>, FACE_LED); // red
            }
            else
            {
                llSetColor(<0, 255, 0>,  FACE_LED); // green
            }        
        }
        //llOwnerSay("debug: llsetparcelmusic reached, playing " + current_station);
        
        llSetTimerEvent(0.0); // stop the "last URL" timer, if any
        
        llListenRemove(l_handle);
        
    }
    
    timer()
    {
        llSetTimerEvent(0.0); // stop the "last URL" timer
        
        current_station = freeURL_last_station; //retrieve the last listed URL
        
        if (is_own_land) llSetParcelMusicURL(current_station);
        else llSay(RELAY_CHANNEL, current_station);
        
        llSay(0, "FM station was reset");
    }
    
    on_rez(integer start_param)
    {
        llResetScript();
    }
    
    changed(integer change)
    {
        if(change & CHANGED_OWNER)  llResetScript();
    
        if (change & CHANGED_INVENTORY) llResetScript();
    } 
}

state read_admin
{
    state_entry()
    {
        llSay(0, "Reading administrator settings (if any)...");
    
    // read the admin here!
        
        if (llGetInventoryKey("_admin") == NULL_KEY) // no admin notecard present
        {
            admin = llGetOwner(); //if no admin card available (works in most cases), simply the owner is the admin.

            llSay(0, "No dedicated admin found (NULL_KEY), setting to 'owner'.");
            
            state read_card;
        }
        else
        {        
            gName = "_admin";
            
            llSay(0, "Looking for any admin settings...");
            gQueryID = llGetNotecardLine(gName, gLine);    // request first line
        }
    }
            
    dataserver(key query_id, string data) 
    {
        
        admin = (key)data;  //read the UUID string from the notecard and convert it to a key.
        if(admin == NULL_KEY)
        {
            llSay(0, "No dedicated admin found (NULL_KEY). Inspect and correct _admin notecard if necessary. Until then, the owner stays admin.");
        }
        else
        {
            
            llSay(0, "Administrator found: " + llGetDisplayName( admin ) + "\nNOTE: if the admin is not present here, no name will be indicated");
        }
        
        
        state read_card;
    }
    
    
        
}

state select_genre //note: atm no more than 10 entries are allowed, to not exceed the llDialog list!
{
    state_entry()
    {
        integer i;
        integer no_of_cards = llGetInventoryNumber(INVENTORY_NOTECARD);
        
        if (no_of_cards >10) 
        {
            no_of_cards = 10;
            llSay(0, "Too many genres/ niches notecards, truncating to 10.");
        }
        
        genre = [];
        
        for (i=1; i< no_of_cards; i++)
        {
            genre += [llGetInventoryName(INVENTORY_NOTECARD, i)];
            
        }
        
        l_handle = llListen(channel, "", NULL_KEY, "");
        
        llSetTimerEvent(20.0); // 20 s timeout
        
        llDialog(toucher, "Choose a musice genre/ niche preselection:", genre, channel);
        
        
    }
    
    listen(integer channel, string name, key id, string message)
    {
        stations_card = message;
        
        //llSay(0, stations_card + " selected.");
        
        llListenRemove(l_handle);
        
        genre_changed = TRUE;
        
        state read_card;
    }
    
    touch_start(integer total_number) //abort only
    {
        llSay(0, "Genre select aborted.");
        llListenRemove(l_handle);
        state radio;
    }
        
        
    
    timer()
    {
        llSetTimerEvent(0.0);
        
        llListenRemove(l_handle);
        
        state radio; 
    }
}

state read_card //this is executed in the beginning, read a user defined notecard
{
    state_entry()  
    {
        
        station_list = [];
        menu_list = [];
        no_of_stations = 0;
        
        gLine = 0;
        
        gName = stations_card;
        llSay(0, "Loading stations...");
        gQueryID = llGetNotecardLine(gName, gLine);    // request first line
    }

    dataserver(key query_id, string data) 
    {
        
        if (query_id == gQueryID) {
            if (data != EOF) 
            {    // not at the end of the notecard
                string station_line;
                string menu_line;
                
                //llOwnerSay("Debug: line " + (string)gLine  + " reads: " + data);
                
                
                if (llGetSubString(data, 0,0) == "#" || llGetSubString(data, 0,0) == "") //skip this line, it's a comment or nothing
                {
                    ++gLine;
                    //llOwnerSay("Debug: comment skipped");
                }
                else // parse the line and divide in two sections: menu button and action (plus particle names?)
                { 
                    integer line_length = llStringLength(data);
                    integer i = 1;
                    
                    i = llSubStringIndex(data, ";"); //find the ; delimiter
                    
                    menu_line = llGetSubString(data, 0, i-1); // part 1 is the menu button
                    
                    // llOwnerSay( "Debug line 80: menu_line = " +  menu_line);
                    if (llStringLength(menu_line) > 12) menu_line = llDeleteSubString(menu_line, 12, -1); // shorten menu_list to 12!  
                    menu_list += [menu_line];
                    
                    //llOwnerSay("Debug - menu item: " + llGetSubString(menu_line, 0, i-1));
                        
                        
                
                    station_list += [llGetSubString(data, i+1, -1)]; // part two is the chat entry
                    
                    
                        
                    //llOwnerSay("Debug: menu: " + llList2String(menu_list, no_of_stations) + " action: " + llList2String(station_list, no_of_stations));
                    //llOwnerSay("Station #" + (string)(no_of_stations+1) + ": " + llList2String(menu_list, no_of_stations) +   " found");

                    no_of_stations++;
                    
                    ++gLine;   
                    
                }
                
                             // increase line count
                gQueryID = llGetNotecardLine(gName, gLine);    // request next line
            }
            else 
            {
                no_of_stations= llGetListLength(station_list);
                
                //llOwnerSay((string)no_of_stations + " stations found in " + stations_card + "."); 
                
                llSay(0, "done, genre: " + stations_card + ".");
                no_of_pages = 1 + no_of_stations/7;
                
                //llSay(0, "debug: no_of_pages = " + (string)no_of_pages);
                
                state radio; 
            }
        }
    }
    
    on_rez(integer start_param)
    {
        llResetScript();
    }
    
    changed(integer change)
    {
        if(change & CHANGED_OWNER)  llResetScript();
    
        if (change & CHANGED_INVENTORY) llResetScript();
    } 
}

state options
{
    state_entry()
    {
        string HELPTEXT = "\nAcess: Group or everybody\nChannel: Change control channel";
        
        l_handle = llListen(channel, "", NULL_KEY, "");
        
        llDialog(toucher, "Select an option:" + HELPTEXT, ["Access", "Channel"], channel);
    }
    
    listen(integer channel, string name, key id, string message)
    {
        
        
        if (message == "Access")
        {   
            llDialog(toucher, "Select access rights:", ["Owner", "Group", "All"], channel);
            
            return;
        }
        
        
        if (message == "Owner") 
        {
            is_owneronly = TRUE;
            is_grouponly = FALSE;
            
            llSay(0, "Access rights are set to owner only.");            
            
        }
        if (message == "Group") 
        {
            is_grouponly = TRUE;
            is_owneronly = FALSE;
            
            llSay(0, "Access rights are set to Group only.");            
            
        }
        
        if (message == "All") 
        {
            is_grouponly = FALSE;
            is_owneronly = FALSE;
            
            llSay(0, "Access rights are set to everybody.");            
            
        }
        
        if (message == "Channel")
        {
            channel = CHANNEL + (integer)llFrand(20);
            
            llSay(0, "Control channel was set to " + (string)channel);
        }
        
        llListenRemove(l_handle);
    
        state radio;
    }
    
    touch_start(integer total_number)
    {
        llSay(0, "Options aborted, returning to radio mode.");
        
        llListenRemove(l_handle);
        
        state radio;
    }
    
    
    
}

state free_url
{
    state_entry()
    {
        llSetTimerEvent(30.0);
        
        llSay(0, "You now have 30 seconds time to enter a custom stream URL into the public chat.");
        
        llListen(0, "", toucher, "");
    }
    
    listen(integer channel, string name, key id, string message)
    {
        if (llGetSubString(message, 0, 6) == "http://" || llGetSubString(message, 0, 7) == "https://")
        {
            //this is a valid mp3 url heading, continue
            
            freeURL_last_station = current_station; // save last station before it is overwritten
            
            current_station = message;
            
            now_playing = "Custom stream URL";
        
            //llOwnerSay("Debug - selected station is " + current_station);
        
            
            if (is_own_land) llSetParcelMusicURL(current_station);
            else llSay(RELAY_CHANNEL, current_station);
            
            llSay(0, "FM station was changed to a custom URL.");
            
            
            
            integer hours = llFloor(freeURL_reset_time/3600);
            integer rest = (integer)freeURL_reset_time - hours*3600;
            integer minutes = llFloor(rest/60);
            rest = rest - minutes*60;
            integer seconds = rest;
            
            llSay(0, "This station will be reset in " + (string)hours + " hour(s), "+ (string)minutes + " minute(s) and " + (string)seconds + " seconds.");
                        
            llSetTimerEvent (freeURL_reset_time); // set timeout clock to a defined return time to last station.
            
            
            
        }
        else
        {
            llSay(0, "This is no valid http:// URL, please repeat.");
        }
        
        state radio;
    }
        
    timer()
    {
        llSay(0, "Entering a custom URL was timed out. Please repeat.");
        
        llSetTimerEvent (0.0); // stop the timeout clock
        
        state radio; // return to normal operation
    }
      
    touch_start(integer total_number)
    {
        llSetTimerEvent(0.0);
        llSay(0, "Entering of a free URL aborted.");
        
        state radio;
    }
}
