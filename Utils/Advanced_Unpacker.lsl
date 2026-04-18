//Advanced Unpacker Script - May 2015

//Gives all items in a folder to owner
//Note: Non-copy items are given separately

//IMPORTANT: Set script to No Modify before
//giving away if using the SmartBot options

//Change your settings at the top of script


// OWNER MAIN SETTINGS // -----------------------------------

integer excludescripts = FALSE; //Set TRUE to not unpack scripts, including itself
integer unpackonrez = FALSE; //UnPack on rez? Set FALSE for touch only

string  customfolder = ""; //Custom folder name, leave blank to use object name

integer texmode = 1; //0 = None | 1 = Both Lines | 2 = 2nd Line Only
string floattext = "Touch to Copy to Inventory"; //2nd line of float text
vector textcolor = <1,1,1>; //Use color finder to get color vector

integer rezmessage = TRUE; //Give message to owner on rez?
string rezmessagetext = "Thank you for your purchase. Touch to unpack."; //Message to owner on rez

integer unpackmessage = TRUE; //Give message to owner on unpack?
string unpackmessagetext = "Please accept your items."; //Message to owner on unpack

integer dieafter = FALSE; //Destroy after unpacked? Object and contents will die.
integer dieseconds = 60; //How many seconds until die?

integer groupinvite = 0; //0 = None | 1 = On Rez | 2 = On Unpack | 3 = Both
string groupkey = "00000000-0000-0000-0000-000000000000"; //get from group key finder

// END MAIN SETTINGS // -------------------------------------


// SMART BOT OPTIONS // ------------------------------------

// Requires SmartBot service and web account
// Learn more about SmartBots group invitations: https://www.mysmartbots.com/

integer smartbot = 0; //0 = None | 1 = On Rez | 2 = On Unpack | 3 = Both
    
string  botgroup = ""; //Your Group Name (must be listed with SmartBots!)

string  botsecurity = ""; //Security Code for your group - Learn more: https://www.mysmartbots.com/docs/Security_code

string  botapi = ""; //Your Developers API Key - Learn more: https://www.mysmartbots.com/docs/Developer%27s_API_key

string  botmessage = ""; //Invitation Message
    
// END SMART BOT OPTIONS // --------------------------------



// BEGIN MAIN CODE /////////////////////////////////////////


unpack() //main function
{
    if (unpackmessage == TRUE)
    {
        llRegionSayTo(llGetOwner(), 0, unpackmessagetext);
    }
    string folnam = llGetObjectName();
    if (customfolder != "")
    {
        folnam = customfolder;
    }
    list inventoryItems;
    list nocopyItems;
    integer inventoryNumber = llGetInventoryNumber(INVENTORY_ALL);
    integer index;
    for ( ; index < inventoryNumber; ++index )
    {
        string itemName = llGetInventoryName(INVENTORY_ALL, index);
        if(llGetInventoryType(itemName) != INVENTORY_SCRIPT || excludescripts == FALSE)
        {
            if (llGetInventoryPermMask(itemName, MASK_OWNER) & PERM_COPY)
            {
                inventoryItems += itemName;
            }
            else
            {
                nocopyItems += itemName;
            }
        }
    }
    if (nocopyItems != [] )
    {
        index = 0;
        integer nocopyNumber = llGetListLength(nocopyItems);
        for ( ; index < nocopyNumber; ++index )
        {
            string itemName = llList2String(nocopyItems, index);
            llGiveInventory(llGetOwner(), itemName);
        }
    }
    if (inventoryItems != [] )
        llGiveInventoryList(llGetOwner(), folnam, inventoryItems);
    if (smartbot > 1)
    {
        botinvite();
    }
    if (groupinvite > 1)
    {
        llOwnerSay(grouptext());
    }
    if (dieafter == TRUE)
    {
        llRegionSayTo(llGetOwner(), 0, "This object will self-destruct in "+(string)dieseconds+" seconds.");
        if (dieseconds > 0)
        {
            llSleep(dieseconds);
        }
        llDie();
    }
}

settext() //float text
{
    if (texmode == 1) //both
    {
        llSetText(llGetObjectName() + "\n" + floattext, textcolor, 1);
    }
    else if (texmode == 2) //2nd line only
    {
        llSetText(floattext, textcolor, 1);
    }
    else //no text
    {
        llSetText("", textcolor, 1);
    }
}

string grouptext() //group text invite
{
    return "Click the link from Chat History (Ctrl+H) and then click on JOIN button! secondlife:///app/group/" + groupkey + "/about";
}

key httprequest;

botinvite() // smartbot invite
{
    string params = llDumpList2String([
    "action="  + "invite",
    "apikey="  + llEscapeURL(botapi),
    "secret="  + llEscapeURL(botsecurity),
    "group="   + llEscapeURL(botgroup),
    "slkey="   + (string)llGetOwner(),
    "force="   + "1",
    "message=" + llEscapeURL(botmessage)],
    "&");
 
  httprequest = llHTTPRequest(
    "http://api.mysmartbots.com/api/simple.html",
    [HTTP_METHOD,"POST"],
    params
   );
}

default
{
    on_rez( integer start_param )
    {
        settext();
        if (rezmessage == TRUE)
        {
            llRegionSayTo(llGetOwner(), 0, rezmessagetext);
        }
        if (unpackonrez == TRUE)
        {
            unpack();
        }
        else
        {
            if (smartbot == 1 || smartbot == 3)
            {
                botinvite();
            }
            if (groupinvite == 1 || groupinvite == 3)
            {
                llOwnerSay(grouptext());
            }
        }
    }
    
    state_entry()
    {
        settext();
    }

    touch_start( integer n )
    {
        integer i;
        for( i = 0; i < n; i++ )
        {
            if (llDetectedKey(i) == llGetOwner()) //owner
            {
                unpack();
            }
        }
    }
    
    http_response( key request_id, integer status, list metadata, string body )
    {
        if (request_id != httprequest)
            return;
 
        if (body != "OK")
        {
            llOwnerSay("SmartBots returned an error: " + body);
        }
    }
}
