integer CHANNEL; //change this in both the radio AND the remote if required

integer is_grouponly=FALSE; //Group access rights, change this to "TRUE" if you want group operation only
integer is_owneronly=FALSE; //Owner access right, change this to "TRUE" if you want owner operation only

key server_key = NULL_KEY; //serves for the UUID of the linked parcel radio server
key toucher = NULL_KEY; // who touched the remote

integer setup_complete = FALSE;


string gName;
            
key gQueryID;
            
integer gLine;


default
{
    state_entry()
    {
        
        state read_channelno;
        
    }

    
    
}

state operation
{

    state_entry()
    {
        
       llListen(CHANNEL, "", NULL_KEY, ""); //open the com channel to the server
       llListen(0, "", NULL_KEY, ""); //listen for nearby commands to relay
       llRegionSay(CHANNEL, "[*subscribe*]"); //request the servers UUID
    }
    
    listen(integer channel, string name, key id, string message)
    {
        
        //llWhisper(0, "debug - message received, channel= " + (string)channel + " , message=" + message);
        
        if(channel == CHANNEL && !setup_complete)
        {
            server_key = (key)message;
            
            llWhisper(0, "server key received: " + message);
            
            setup_complete = TRUE;
            
            
            
        }
       
        
    }
    
    touch_start(integer total_number)
    {
        
        toucher = llDetectedKey(0);
    
        if (is_grouponly && llSameGroup(toucher) == FALSE)
        {
            llInstantMessage(toucher, "Sorry, operation is only allowed for group members.");
        
            return;
        }
        
        if (is_owneronly)
        {
            llInstantMessage(toucher, "Sorry, operation is only allowed for the owner/administrator of this radio set.");
        
            return;
        }
            
        if (server_key != NULL_KEY) //if setup is proper and complete
        {
            llRegionSayTo(server_key, CHANNEL, "[*menu*]" + (string)toucher); // send the touchers UUID, to the server only to asvoid region spamming; request the llDialog menu
        }
        
    }

    
    on_rez(integer start_param)
    {
        llResetScript();
    }
    
    changed(integer change)
    {
        if(change & CHANGED_OWNER)  llResetScript();
    
        if(change & CHANGED_INVENTORY) llResetScript();
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
            
            llSay(0, "The radio remote will shut down for now.");
            
            
            
        }
        else
        {  
            gName = "_channel";
            
            key gQueryID;
            
            integer gLine = 0;
            
           
            gQueryID = llGetNotecardLine(gName, gLine);    // request first line
        }
          
    }
            
    dataserver(key query_id, string data) 
    {
        
        CHANNEL = (integer)data;  //read the comm channel line and convert it to a number
        
        llSay(0, "CHANNEL set to "+ (string)CHANNEL);
        
        state operation;
        
       
    }
   
   changed(integer change)
    {
        if(change & CHANGED_OWNER)  llResetScript();
    
        if(change & CHANGED_INVENTORY) llResetScript();
    } 
    
}

