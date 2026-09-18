//improved photo frame

//version 5.0

//by Franklyn Constantine

/* this slide show script serves any single display pane frame; it can be either a single prim, or a link set. It should be possible to turn any modifyable frame, and it does not matter if it is a classic prim or mesh, to a slide show with frequently changing pictures.
 
To make it work you have to inspect the frame first and need to identify:
- which is the link child number (if any) which shall display the pictures?
- which is the prim face (aka side) which shall display the pictures?

Both information can be taken from your frames object description. Apply these numbers to the configuration variables below, and then drop your script
to the frame.

*/



// configuration variables, change these to match the script to your frame
integer LINKNO = 0; // change this to define the target child which holds your picture pane
// link number = 0 is an unlinked prim, it will work like the llSetTexture() instruction.

integer SIDE = 1; // change this to the picture pane of your frame (everything would be ALL_SIDES, but it is very unlikely you need that)

integer DROP = FALSE; // if you allow others to drop pictures to the frame (default: No). If you want to, change this to TRUE


//------------- Do not change anything below (except you know what you are doing!)
// Globals
//-------------

integer channel; // the control channel
integer c_handle; //the menu event handler

integer period_channel; //a dedicated channel for change times
integer p_handle; //the handler for change times

key toucher; //the av who touched the frame



string loaded_pic_name = ""; //the pic name to load

integer loaded_pic_no = 0; // the pic index to load

integer no_of_pics = 0; //number of pics in inventory

integer random_pic_no; //a random picture to start with

float period = 600.0; // default slideshow period, 10 min

integer is_active = TRUE; // slidshow on or off?

integer is_changed; // anything changed?

//some llDialog() menus
list OFF_MENU= ["Turn off", "Period", "Info", "Next"];
list ON_MENU= ["Turn on", "Period", "Info"];
list PERIOD_MENU = ["30s", "1min", "5min", "10min", "30min", "1h", "6h", "12h", "1d"];

list menu;



//-------------
// Methods
//-------------

loadPic(integer pic) //puts a texture to the frame prim
{
    loaded_pic_name = llGetInventoryName( INVENTORY_TEXTURE, pic ); //get the texture name from the frame inventory
    
    //llWhisper(0, "Debug: loaded pic #" + (string)pic + " : " + loaded_pic_name);

    llSetLinkTexture(LINKNO, loaded_pic_name, SIDE); //puts a texture to the defined picture pane with link child number and face. 
}

showInfo()
{
    llInstantMessage(toucher, "Currently displaying: " + loaded_pic_name);
}

//-------------
// States
//-------------

default
{
    state_entry()
    {  
    
        llAllowInventoryDrop( DROP );   
           
        channel= 1000 + llFloor(llFrand(100)); //assign a communication channel. It is random to avoid interference with other frames.
        
        period_channel=channel + 2; // the second com channel is 2 digits higher
        
        no_of_pics = llGetInventoryNumber(INVENTORY_TEXTURE);  // how many pictures are residing in the inventory?
        
        if(!no_of_pics) 
        {
            llWhisper(0, "There are no pictures to display - please drop some first!");
        }
        else
        {
            random_pic_no = llFloor(llFrand(no_of_pics)); // select a random start picture
            
            state slideshow; 
        }
    }
    
    changed(integer change)
    {    
        if (change & CHANGED_INVENTORY) llResetScript(); //if inventory has changed, restart
        
    }

    

    on_rez(integer start_param) //reset the scrip when the frame is rezed.
    {
        llResetScript();
    }
}


state slideshow
{
    state_entry()
    {
        
        
        //llListen(period_channel, "", NULL_KEY, "");
        
        llWhisper(0, "FC's Slide Show Photo Frame ready.");
        
        loadPic(random_pic_no); //load any picture for the start.
        
                    
    }

    touch_start(integer total_number)
    {

        c_handle = llListen(channel, "", NULL_KEY, ""); //open a channel for the dialog
        
        //llSay(0, "Debug: chosen number: " + (string)random_pic_no);
        
        toucher= llDetectedKey(0); //who is touching?

        if (is_active) // on/ off toggle
        {
            
            llDialog(toucher, "Select your option", OFF_MENU, channel);
        }
        else
        {
                        
            llDialog(toucher, "Select your option", ON_MENU, channel);

        }

    }

    listen(integer channel, string name, key id, string message)
    {    
    
        
        
        if(message == "Turn on")
        {
            llSetTimerEvent(period); //slideshow on
            
            is_active = TRUE;
            
            //llWhisper(0, "Debug: loading pic #" + (string)random_pic_no);
            
            llWhisper(0, "Slide show is on, current display period is " + (string)period + " seconds.");

            loadPic(random_pic_no); //load first pic immediately, random
            
        }
        
        
        if (message == "Turn off")
        {
            llSetTimerEvent(0.0); //slideshow off
    
            is_active = FALSE;
            
            llWhisper(0, "Slide show is off.");
        }
        
        if (message == "Period") 
        {
            p_handle = llListen(period_channel, "", NULL_KEY, "");
            
            llDialog(toucher, "Select the desired period", PERIOD_MENU, period_channel);
        }
        
        if (channel == period_channel)
        {
            
            if (message == "30s") period = 30.0;
            if (message == "1min") period = 60.0;
            if (message == "5min") period = 300.0;
            if (message == "10min") period = 600.0;
            if (message == "30min") period = 1800.0;
            if (message == "1h") period = 3600.0;
            if (message == "6h") period = 21600.0;
            if (message == "12h") period = 43200.0;
            if (message == "1d") period = 86400.0;
                    
            llSetTimerEvent(period);  //set timer to regular value

            llWhisper(0, "Change period was set to " + (string)period + " seconds, slide show turned on");
            
            is_active = TRUE;
            
            
            
            llListenRemove(period_channel);
            
        }
        
        if (message == "Info")
        {
            showInfo();
        }
       
        if (message == "Next")
        {
            
            llSetTimerEvent(0.1);
        } 
        
        toucher = NULL_KEY;
        
        llListenRemove(c_handle);
        
    }

    timer()
    {
        llSetTimerEvent(period);  //set timer to regular value
        
        //llSay(0, "Debug: load pic no: " + (string)loaded_pic_no);
        
        loadPic(loaded_pic_no);

        loaded_pic_no ++;

        if (loaded_pic_no == no_of_pics) loaded_pic_no = 0; //reroll when the last picture was reached
    }

    changed(integer change)
    {    
        if (change & CHANGED_INVENTORY) state default; //if inventory has changed, build a new list
        
    }
}
