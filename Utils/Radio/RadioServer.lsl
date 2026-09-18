//FC's Parcel Music Manager

//version 5.2 for parcel radio servers

//by Franklyn Constantine, 2009-2021 all rights reserved.

//this radio set reads music station URLs from a notecard and sets the parcel music appropriately.

// written under use of free LSL examples


// Terms of use:
// this program must not be sold alone, it may be copied or resold as a part of a new product, 
// as long as it is not the main purpose of the new creation.

// example: put it into a self made radio, or any other unique own creation and sell it - it's OK!
//          put it in a freebie, or any other 3rd party stuff and sell it - this is NOT OK!


// if reused, Franklyn Constantine  shall be mentioned in the credits. 


string VERSION = "5.2.3 (Server Edition)"; //the current version 

integer CHANNEL; //change this in both the radio AND the remote if required

float freeURL_reset_time = 10800.0; // edit this to choose any wanted reset time to last station

//integer FACE_LED=3; //future growth

list genre = []; //categories of stations, added with 5.0
list station_list = [];
list menu_list = [];

list menu_page = []; // a subset of the menu list
list station_page = []; // the same for the station URLs

string now_playing;

integer selected_index;
string current_station;
string freeURL_last_station;

key toucher; // the avatar who touched the remote controller prim

string hovertext = ""; //something to display on top
integer is_hovertext = TRUE; //hovertest enabled (default) or disabled?

integer genre_changed = FALSE; //to assist recall of the station list after a genre change

integer no_of_stations;

integer no_of_pages;

integer current_page = 0; // the current menu page (a part of the index number)

integer l_handle; // the listener handle for radio stations selection

string stations_card; // the name of the genre to play , represented by a notecard

// Read out a complete notecard from the object's inventory.
string gName;    // name of a notecard in the object's inventory
integer gLine = 0;        // current line number
key gQueryID; // id used to identify dataserver queries

//** optics **
integer LED1 = 2; // the power LED face
integer LED2 = 3; // the DISK LED (genre chosen)
integer LED3 = 4; // the LAN LED (a remote asked for connection)
integer LED4 = 5; // the STATUS LED (on/ off)

vector BLUE= <0.000, 0.455, 0.851>; //blue LED
vector GREEN= <0.180, 0.800, 0.251>; //green LED
vector RED = <1.000, 0.255, 0.212>; // red LED
vector WHITE = <0.867, 0.867, 0.867>; // LED off

float GLOW = 0.25;   // LED on
float NOGLOW = 0.0;  // LED Off

float T_LIMIT= 2.0;

buildMenu(integer page)
{
    integer page_index;
    
    menu_page = llList2List(menu_list, (page*7), (page*7)+6); //extract a portion of the stations
    
    station_page = llList2List(station_list, (page*7), (page*8)+6); // dito, for the URL indices
    
    //add some buttons which appear on any menu page
    
    // comment out end
                
    menu_page += ["FREE URL"]; // add any custom URL
                
    //menu_page += ["Off"]; // add an "off" button (enters a 'void' into the parcel URL field) //removed for a genre button
    
    menu_page += ["GENRE"]; // add a "Genre" button for the various niche notecards (added with 5.0)
    menu_page += ["NEXT"]; 
    
    menu_page += ["BACK"];
    
    menu_page += ["OFF"]; // switch off (void stream)
    
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
 
 setHoverText(string text)
 {
     if(is_hovertext) llSetText(text, <0.9, 0.9, 0.9>, 0.9);
     else llSetText("", <0,0,0>, 0);
 }

default
{
    state_entry()
    {
        vector this_land = llGetPos();
        
        hovertext = "FC's Web Radio Server Version " + VERSION;
        
        llSetColor(WHITE, LED2);
        llSetColor(WHITE, LED3);
        llSetColor(WHITE, LED4);
        
        
        llSay(0, hovertext);
                
        stations_card = llGetInventoryName(INVENTORY_NOTECARD, 1); //the initial genre notecard, lowest in alphabet (except _channel which comes first)
        
        if (llGetOwner() != llGetLandOwnerAt(this_land)) 
        {
            llOwnerSay("NOTE: This radio server must be deeded to the land, or it will not work.");
        }
        
       setHoverText(hovertext); 
        
       state read_channelno;
    }

    
}

state radio
{
    state_entry()
    {  
        
        
        l_handle = llListen(CHANNEL, "", NULL_KEY, "");
        
        now_playing = GetCurrentChannel();
        
        hovertext = "Genre: " + stations_card + "\nTuned to: " + now_playing + "\n" + current_station;
        
        setHoverText(hovertext);
        
        if(genre_changed)
        {
            
            l_handle = llListen(CHANNEL, "", NULL_KEY, "");
            
            buildMenu(0);
            
            genre_changed = FALSE; //reset the genre changed notifier
        
            //llDialog(toucher, "Currently playing \nGenre: " + stations_card + "\nTuned to: " + now_playing +  ".\nSelect a radio station:", menu_page, CHANNEL);
            llDialog(toucher, "Currently playing \nGenre: " + stations_card + "\nTuned to: " + now_playing +  ".\nSelect a radio station:", menu_page, CHANNEL);
            
                
            return; 
        }
        
    }
    
    touch_start(integer total_number)
    {
        llResetTime();
        
        llWhisper(0, "forcing hovertext update....");
        setHoverText("...updating...");
        llWhisper(0, "reading parcel stream...");
        //current_station = llGetParcelMusicURL();
        //llSleep(2.0);
        string status_message = "Genre: " + stations_card + "\nTuned to: " + now_playing + "\n" + llGetParcelMusicURL();
        
        llWhisper(0, "Current Radio Server settings:\n" + status_message);
        
        
        setHoverText(status_message);
        
        
    }
    
    touch_end(integer total_number) //if the server was clicked/held for more than T_LIMIT seconds....
    {
        if(llGetTime() > T_LIMIT)
        { //toggle the hovertext indicator
            if (is_hovertext)
            {
                 is_hovertext = FALSE;
                 llWhisper(0, "Hovertext is disabled.");
                 
             }
            else  
            {
               is_hovertext = TRUE;
               llWhisper(0, "Hovertext is enabled.");
             }
             
            setHoverText(hovertext);
        }
    }
        
    
    
    listen(integer channel, string name, key id, string selected)
    {
        //llWhisper(0, "debug - message " + selected + " received from " + (string)id + " (" + name + ") on channel " + (string)channel);
        
        
        
        if(selected == "[*subscribe*]")
        {
            key this_key = llGetKey();
            
            llRegionSay(CHANNEL, llGetKey());
            
            llSetColor(GREEN, LED3);
            
            return;
            
        }
        if (llGetSubString( selected, 0, 7 ) == "[*menu*]") //cutting off the keyword and parse
        {
            toucher = (key)llGetSubString( selected, 8, -1) ; // note the UUID who touched the radio remote
            
            //llWhisper(0, "debug - toucher set to " + (string)toucher);
            
            buildMenu(current_page);
    
            now_playing = GetCurrentChannel();
            
            llSetColor(GREEN, LED3);
                        
            llDialog(toucher, "Currently playing \nGenre: " + stations_card + "\nTuned to: " + now_playing +  ".\nSelect a radio station:", menu_page, CHANNEL);
            
            
            
            return;
            
        }
            
            
       
        
        
        if (selected == "GENRE")
        {
            
            llSetColor(RED, LED2);
            
            state select_genre;
        }
        
        
        
            
        if (selected == "NEXT")
        {
            current_page++;
                
            if (current_page > no_of_pages-1) current_page = 0; //reroll
                
            //llSay(0, "debug - current page = " + (string)current_page);
                
            buildMenu(current_page);
        
            llDialog(toucher, "Currently playing \nGenre: " + stations_card + "\nTuned to: " + now_playing +  ".\nSelect a radio station:", menu_page, CHANNEL);
                
            return; 
        }
            
        if (selected == "BACK")
        {
            //llSay(0, "debug - current page = " + (string)current_page);
                
            if (current_page == 0) current_page = no_of_pages;
            else current_page--;
                
            buildMenu(current_page);
        
            llDialog(toucher, "Currently playing \nGenre: " + stations_card + "\nTuned to: " + now_playing +  ".\nSelect a radio station:", menu_page, CHANNEL);
                
            return; 
        }
            
        if (selected == "FREE URL") 
        {
            state free_url;
                
            return;
        }
        
        if (selected == "OFF")
        {
            llSetParcelMusicURL("");
            
            setHoverText("OFF");
            
            llSetColor(RED, LED2);
            
            llInstantMessage(toucher, "FM station was switched off.");
            
            return;
            
        }
        
                    
        now_playing = selected;
        
        selected_index = llListFindList( menu_page, [selected] );
        
        //llOwnerSay("Debug - index for " + selected + " is " + (string)selected_index);
        
        current_station = llList2String(station_page, selected_index);
        
        //llOwnerSay("Debug - selected station is " + current_station);
        
            
        llSetParcelMusicURL(current_station);
        
        llSetColor(GREEN, LED2);
        
        llInstantMessage(toucher, "FM station was changed to "+ selected);
        
        //fix the update flaw?
        now_playing = selected;
        current_station = llGetParcelMusicURL();
        // end fix
        
        
        hovertext = "Genre: " + stations_card + "\nTuned to: " + now_playing + "\n" + current_station;
        
        setHoverText(hovertext);
        
        
        //llOwnerSay("debug: llsetparcelmusic reached, playing " + current_station);
        
        llSetTimerEvent(0.0); // stop the "last URL" timer, if any
        
       
        
    }
    
    timer()
    {
        llSetTimerEvent(0.0); // stop the "last URL" timer
        
        current_station = freeURL_last_station; //retrieve the last listed URL
        
        llSetParcelMusicURL(current_station);
        
        
        //llSay(0, "FM station was reset");
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


    
        


state select_genre //note: atm no more than 10 entries are allowed, to not exceed the llDialog list!
{
    state_entry()
    {
        //llWhisper(0, "debug - state select_genre reached,");
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
            
            //llWhisper(0, "debug - loading: " + llGetInventoryName(INVENTORY_NOTECARD, i));
            
        }
        
        l_handle = llListen(CHANNEL, "", NULL_KEY, "");
        
        llSetTimerEvent(20.0); // 20 s timeout
        
        //llWhisper(0, "debug - current genre list: " + (string)genre);
        
        llDialog(toucher, "Choose a musice genre/ niche preselection:", genre, CHANNEL);
        
        
    }
    
    listen(integer channel, string name, key id, string message)
    {
        //llWhisper(0, "debug - genre message received: " + message);
        
        if(llGetSubString( message, 0, 7 ) == "[*menu*]") //catch erroneous messages due to ignoring the genre menu
        {
            llSetTimerEvent(0.0);
        
            llWhisper(0, "Something went wrong, resetting to radio.");
            
            state radio; 
        }
        else
        {
            
            stations_card = message;
            
            //llSay(0, stations_card + " selected.");
            
            //llListenRemove(l_handle);
            
            genre_changed = TRUE;
            
            state read_card;
        }
    }
    
    
        
        
    
    timer()
    {
        llSetTimerEvent(0.0);
        
        llWhisper(0, "Genre select timeout, resetting to radio.");
        
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
                
                llSetColor(GREEN, LED2);
                
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


    
   
    
    
    


state free_url
{
    state_entry()
    {
        llSetTimerEvent(30.0);
        
        llListen(CHANNEL, "", toucher, "");
        
        
        
        llWhisper(0, "debug - toucher : " + (string)toucher);
        
        llTextBox(toucher, "Enter a custom free URL within 30 seconds:", CHANNEL );
        
        
        
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
        
            
            llSetParcelMusicURL(current_station);
            
            
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
            llInstantMessage(toucher, "This is no valid http:// or https:// URL, please repeat.");
        }
        
        state radio;
    }
        
    timer()
    {
        llInstantMessage(toucher, "Entering a custom URL was timed out. Please repeat.");
        
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


state read_channelno
{
    state_entry()
    {
        llSay(0, "Reading com channel number...");
        
        if (llGetInventoryKey("_channel") == NULL_KEY) // no channel notecard present
        {
            llSay(0, "No channel notecard found. Drop the _channel notecard with a proper number please");
            
            llSay(0, "The radio will shut down for now.");
            
            llSetColor(RED, LED2);
            llSetColor(RED, LED3);
            llSetColor(RED, LED4);
            
        }
        else
        {  
            gName = "_channel";
            
           
            gQueryID = llGetNotecardLine(gName, gLine);    // request first line
        }
          
    }
            
    dataserver(key query_id, string data) 
    {
        
        CHANNEL = (integer)data;  //read the comm channel line and convert it to a number
        
        llSay(0, "CHANNEL set to "+ (string)CHANNEL);
        
        llSetColor(RED, LED2);
        llSetColor(RED, LED3);
        llSetColor(GREEN, LED4);
    
        state read_card ;
    }
   
   changed(integer change)
    {
        if(change & CHANGED_OWNER)  llResetScript();
    
        if(change & CHANGED_INVENTORY) llResetScript();
    } 
    
}
        
