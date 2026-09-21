//Franklyn's improved LOLO clouds controller
// 2018
// this software is not affiliated with the LOLO clouds system, use at own risk.


integer M_CHANNEL = 10355; //the HUD Dialog channel

//the  settings below follow the LOLO cloud description & manual, changes not recommended.
integer C_CHANNEL = 9 ; //the cloud control channel iaw LOLO default
string CLEAR_SKY = "clear sky"; //the keywords to which the cloud seeds listen
string WHITE_CLOUD = "white cloud";
string GREY_CLOUD = "grey cloud";
string RAIN_CLOUD= "rain cloud";
string STORM_CLOUD = "storm cloud";
string SNOW_CLOUD = "snow cloud";
//end of genuine LOLO settings

integer is_fair = TRUE; //the different cloud types ,  are they activated or not? (default is all off)
integer is_white = FALSE;
integer is_grey = FALSE;
integer is_rain = FALSE;
integer is_storm = FALSE;
integer is_snow = FALSE;

integer mode_is_set = FALSE; //enforce settings on first use
integer time_is_set = FALSE;

integer is_random = FALSE; // random time schedule, default is off

string current_cloud; //the current active cloud
string current_schedule = "OFF"; //startup time schedule is none
string current_time; // the selected time schedule

integer is_on = FALSE; // whether the clouds  are on or off

integer change_minutes = 30; // the factory default changing time 

list active_menu; //which buttons shall appear
string on_off_text = "Activate"; //a menu button, default 

list active_list; // which cloud types are active and cycling
integer no_of_active_clouds; // how many clouds are active?


string status; 

key toucher;

integer l_handle; // the listener

buildActiveMenu() //build the menu
{
        active_menu = [];
        
        // (fair (= clear sky) is always enabled
        if (is_white) active_menu += ["♦ white"] ;
        else active_menu += ["white"] ;
        if (is_grey) active_menu += ["♦ grey"] ;
        else active_menu += ["grey"] ;
        if (is_rain) active_menu += ["♦ rain"] ;
        else active_menu += ["rain"] ;
        if (is_storm) active_menu += ["♦ storm"] ;
        else active_menu += ["storm"] ;
        if (is_snow) active_menu += ["♦ snow"] ;
        else active_menu += ["snow"] ;
        
        active_menu += ["Done"];
        
}

integer buildActiveList() //add selected cloud types to the change schedule
{
    active_list = []; //clear the list
    
    active_list += [CLEAR_SKY]; //fair is always active
    if (is_white) active_list += [WHITE_CLOUD];
    if (is_grey) active_list += [GREY_CLOUD];
    if (is_rain) active_list += [RAIN_CLOUD];
    if (is_storm) active_list += [STORM_CLOUD];
    if (is_snow) active_list += [SNOW_CLOUD];
    
     
    return llGetListLength(active_list); 
}

string selectCloud() //select a new cloud type randomly
{
     string next_cloud ;
    do 
    {
        next_cloud = llList2String( active_list, (integer)llFrand(no_of_active_clouds)  );
        
        
    } while (current_cloud == next_cloud); //exclude the same choice, try again

    return next_cloud;
}

showStatus() //show a float text
{
    status = "Current schedule: " + current_schedule + "\nCurrent weather: " + current_cloud;
            
    llSetText(status, <0.9, 0.9, 0.9>, 0.75);
}

default
{
    state_entry()
    {
        
        current_cloud = CLEAR_SKY; //default 
        llShout(C_CHANNEL, CLEAR_SKY); //start always fair
        
        
        llSay(0, "Franklyn's LOLO scheduler 1.0 ready using channel " + (string)C_CHANNEL + ".");
        
        state running;
        
    }
}

state running
{
    state_entry()
    {
        
        
        no_of_active_clouds = buildActiveList(); //create the list of active clouds
        
            
        if (is_on) //if the scheduler is enabled, then
        {
             llSetTimerEvent((float)change_minutes * 60); //change every x minutes
             
             if (is_random) llSetTimerEvent(llFrand(10000)+ 300.0); //change at a random time, max ~ 3 hours
             
         
             current_cloud = selectCloud();   
             
             current_schedule = current_time;
            
            llShout(C_CHANNEL, current_cloud);  
            
            showStatus();
             
        }
        else //the scheduler is not on.
        {
             llSetTimerEvent(0.0); // no change at all
             current_cloud = CLEAR_SKY; //reset to fair weather
             current_schedule = "OFF";
             
             llShout(C_CHANNEL, current_cloud);  
             
             showStatus();
        }
             
             
        
      
        llListen(C_CHANNEL, "", NULL_KEY, ""); //listen to other LOLO controllers working on the clouds control channel, to keep it constent.
        
        
         showStatus(); // and note their last command.
    }

    touch_start(integer total_number)
    {
        l_handle = llListen(M_CHANNEL, "", llGetOwner(), ""); //it works for the owner only
        
        
        toucher = llDetectedKey(0);
        
        if (toucher !=llGetOwner()) return;
        
        if(!mode_is_set)  //if no clouds are selected, enforce the setup menu
        {
            state set_clouds; //to choose the cloud types
        }
       
        
        llDialog(toucher, "Select Options", ["set clouds", "set time" , on_off_text], M_CHANNEL);
        
    }
    
    listen(integer channel, string name, key id, string message)
    {
        if(channel ==9) //if there are any other incoming messages on Ch. #9 (e.g. by the genuine LOLO controller)
        {
            current_cloud = message;
            
            showStatus();
            return;
        }
        
        if (message == "set clouds")
        {
            state set_clouds;
        }
        
        if (message == "set time")
        {
            state set_time;
        }
        
        if (message == "Activate")
        {
            is_on = TRUE;
            on_off_text = "Deactivate";
            
           
            
        }
        
        if (message == "Deactivate")
        {
            is_on = FALSE;
            is_fair = TRUE;
            on_off_text = "Activate";
            current_schedule = "OFF";
            llShout(C_CHANNEL, CLEAR_SKY);  
            
        }
        
        state rerun;
        
        
    }
    
    timer()
    {
        if(!is_fair)  // always clear sky after clouds
        {
            
            current_cloud = CLEAR_SKY; 
            is_fair = TRUE;
            
            
        }
        else //if weather was fair before, choose a cloud style
        {
        
            current_cloud = selectCloud();  
            is_fair = FALSE; 
            
        }
        
        llShout(C_CHANNEL, current_cloud);  
        
        
        showStatus();
        
        if (is_random) llSetTimerEvent(llFrand(10000)+ 300.0); //if the schedule is at random, select a new (different) change time
    }
    
}

state set_clouds
{
    state_entry()
    {
        buildActiveMenu(); //build a new menu for cloud selection
        
        l_handle = llListen(M_CHANNEL, "", llGetOwner(), "");
        
        llSetTimerEvent(60.0);
       
        
        llDialog(toucher, "Select active cloud types (♦ = active) \n(Clear Sky is always selected).", active_menu, M_CHANNEL);
        
    
        
    }
    listen(integer channel, string name, key id, string message)
    {
        
        
        if (message == "Done")
        {
            llListenRemove(l_handle);
            
            mode_is_set = TRUE;
            
            no_of_active_clouds = buildActiveList();
            
            //llInstantMessage(toucher, "Following clouds are selected: " + (string)active_list);
            
             
            if(!time_is_set)
            {
                state set_time;
            }
            else state running;
        }
        
       
       
        if (llSubStringIndex( message, "white" ) > -1) 
        {
            if (llSubStringIndex( message, "white" ) > 0) is_white = FALSE;
            else is_white = TRUE;
            
            buildActiveMenu(); //build a new menu for cloud selection

            llDialog(toucher, "Select active cloud types (♦ = active)", active_menu, M_CHANNEL);
            
        } 
        
         if (llSubStringIndex( message, "grey" ) > -1) 
        {
            if (llSubStringIndex( message, "grey" ) > 0) is_grey = FALSE;
            else is_grey = TRUE;
            
            buildActiveMenu(); //build a new menu for cloud selection

            llDialog(toucher, "Select active cloud types (♦ = active)", active_menu, M_CHANNEL);
            
        }
        if (llSubStringIndex( message, "rain" ) > -1) 
        {
            if (llSubStringIndex( message, "rain" ) > 0) is_rain = FALSE;
            else is_rain = TRUE;
            
            buildActiveMenu(); //build a new menu for cloud selection

            llDialog(toucher, "Select active cloud types (♦ = active)", active_menu, M_CHANNEL);
            
        }
        
        if (llSubStringIndex( message, "storm" ) > -1) 
        {
            if (llSubStringIndex( message, "storm" ) > 0) is_storm = FALSE;
            else is_storm = TRUE;
            
            buildActiveMenu(); //build a new menu for cloud selection

            llDialog(toucher, "Select active cloud types (♦ = active)", active_menu, M_CHANNEL);
            
        }
        
        if (llSubStringIndex( message, "snow" ) > -1) 
        {
            if (llSubStringIndex( message, "snow" ) > 0) is_snow = FALSE;
            else is_snow = TRUE;
            
            buildActiveMenu(); //build a new menu for cloud selection

            llDialog(toucher, "Select active cloud types (♦ = active)", active_menu, M_CHANNEL);
            
        }
    }
    
     timer()
    {
        llInstantMessage(toucher, "Settings timed out, please try again.");
        
        state running;
        
    }
    
    
}

state set_time
{
    state_entry()
    {
        l_handle = llListen(M_CHANNEL, "", llGetOwner(), "");
        
        llSetTimerEvent(60.0);
        
        llDialog(toucher, "Set an average time", ["OFF", "5 minutes", "10 minutes", "30 minutes" , "1 hour", "2 hours", "6 hours" , "daily", "random"], M_CHANNEL);
    }
    
    listen(integer channel, string name, key id, string message)
    {
        current_schedule = message;
        
        is_random = FALSE;
        
        if(message == "OFF") 
        {
            
            is_on = FALSE;
            
            state running;
        }
        current_time = current_schedule;
        
        if (message == "5 minutes") change_minutes = 5;
        if (message == "10 minutes") change_minutes = 10;
        if (message == "30 minutes") change_minutes = 30;
        if (message == "1 hour") change_minutes = 60;
        if (message == "2 hours") change_minutes = 120;
        if (message == "6 hours") change_minutes = 360;
        if (message == "daily") change_minutes = 1440;
        if (message == "random") is_random = TRUE;
        
        time_is_set = TRUE;
        is_on = TRUE;
        on_off_text = "Deactivate";
        
        llListenRemove(l_handle);
        
        state running;
    }
    
    timer()
    {
        llInstantMessage(toucher, "Settings timed out, please try again.");
        
        state running;
        
    }
        
}

state rerun
{
    state_entry()
    {
        state running;
    }
}
