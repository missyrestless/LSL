// DJ Tip Jar Script with Tip Splitting, Profile Pictures, and Fallback
// Built for Second Life LSL by Alavandier Dragonheart
key currentDJ;
string djName = "";
integer djLoggedIn = FALSE;
float maxTime = 3600.0;
float checkInterval = 30.0;
float maxDistance = 15.0;

string fallbackTexture = "Your_Club_Texture_Name_Here"; // Name of your fallback texture

string profile_key_prefix = "<meta name=\"imageid\" content=\"";
string profile_img_prefix = "<img alt=\"profile image\" src=\"http://secondlife.com/app/image/";
integer profile_key_prefix_length;
integer profile_img_prefix_length;

list sides;
list deftextures;
key lastRequestID;

integer tipSplit = 100; // % given to DJ (default 100)
key setupUser;

integer dialogChannel = -999;
integer dialogHandle;

list tipNames;
list tipAmounts;


GetDefaultTextures()
{
    integer i;
    integer faces = llGetNumberOfSides();
    for (i = 0; i < faces; i++)
    {
        sides += i;
        deftextures += llGetTexture(i);
    }
}

UseFallbackTexture()
{
    if (llGetInventoryType(fallbackTexture) == INVENTORY_TEXTURE)
    {
        llSetTexture(fallbackTexture, 3);
    }
    else
    {
        llOwnerSay("⚠️ Fallback texture not found in inventory: " + fallbackTexture);
        SetDefaultTextures();
    }
}

SetDefaultTextures()
{
    integer i;
    integer faces = llGetNumberOfSides();
    for (i = 0; i < faces; i++)
    {
        llSetTexture(llList2String(deftextures, i), i);
    }
}

GetProfilePic(key id)
{
    string url = "https://world.secondlife.com/resident/" + (string)id;
    lastRequestID = llHTTPRequest(url, [HTTP_METHOD, "GET"], "");
}


logTip(key id, integer amount)
{
    if (djLoggedIn)
    {
        string tipper = llKey2Name(id);
        llWhisper(0, "💸 Tip from " + tipper + ": L$" + (string)amount);
    }
}

default
{
    state_entry()
    {
        profile_key_prefix_length = llStringLength(profile_key_prefix);
        profile_img_prefix_length = llStringLength(profile_img_prefix);
        GetDefaultTextures();

        llSetText("🎶 Touch to Login as DJ 🎶", <1,1,1>, 1.0);
        llRequestPermissions(llGetOwner(), PERMISSION_DEBIT);
    }

    run_time_permissions(integer perms)
    {
        if (!(perms & PERMISSION_DEBIT))
        {
            llOwnerSay("⚠️ This script needs debit permissions to send money to DJs.");
        }
    }

    touch_start(integer total_number)
    {
        key toucher = llDetectedKey(0);

        // Owner setup menu
        if (toucher == llGetOwner() && !djLoggedIn)
        {
            setupUser = toucher;
            llListenRemove(dialogHandle);
            dialogHandle = llListen(dialogChannel, "", toucher, "");

            llTextBox(toucher, "Enter DJ Tip % (0-100):", dialogChannel);
            return;
        }

        if (!llSameGroup(toucher))
        {
            llInstantMessage(toucher, "You must be in the same group to log in as DJ.");
            return;
        }

        if (!djLoggedIn)
        {
            currentDJ = toucher;
            djName = llKey2Name(currentDJ);
            djLoggedIn = TRUE;

            llSetText("🎧 DJ: " + djName + " 🎧\nTips Welcome!", <0.5,1.0,0.5>, 1.0);
            llInstantMessage(currentDJ, "You are now logged in as DJ.");
            llSetTimerEvent(checkInterval);
            GetProfilePic(currentDJ);
        }
        else if (toucher == currentDJ)
        {
            djLoggedIn = FALSE;
            currentDJ = NULL_KEY;
            djName = "";
            llSetText("🎶 Touch to Login as DJ 🎶", <1,1,1>, 1.0);
            llInstantMessage(toucher, "You have logged out.");
            UseFallbackTexture();
            llSetTimerEvent(0.0);
        }
        else
        {
            llInstantMessage(toucher, "A DJ is already logged in.");
        }
    }

    money(key id, integer amount)
    {
        if (!djLoggedIn || id == currentDJ) return;

        logTip(id, amount);

        integer djShare = (amount * tipSplit) / 100;
        integer ownerShare = amount - djShare;

        if (djShare > 0)
        {
            llGiveMoney(currentDJ, djShare);
            llInstantMessage(currentDJ, "You received a tip of L$" + (string)djShare + " from " + llKey2Name(id) + "!");
        }

        if (ownerShare > 0)
        {
            llInstantMessage(llGetOwner(), "You retained L$" + (string)ownerShare + " from a tip.");
        }
    }

    
listen(integer channel, string name, key id, string message)
{
    if (id != setupUser) return;

    integer input = (integer)message;
    if (input >= 0 && input <= 100)
    {
        tipSplit = input;
        llOwnerSay("✅ Tip split updated: " + (string)tipSplit + "% to DJ.");
    }
    else
    {
        llOwnerSay("⚠️ Invalid input. Please enter a number between 0 and 100.");
    }
    llListenRemove(dialogHandle);

    }

    timer()
    {
        if (!djLoggedIn) return;

        vector djPos = llList2Vector(llGetObjectDetails(currentDJ, [OBJECT_POS]), 0);
        vector jarPos = llGetPos();
        float distance = llVecDist(djPos, jarPos);

        if (distance > maxDistance)
        {
            llInstantMessage(currentDJ, "You were too far from the tip jar and have been logged out.");
            djLoggedIn = FALSE;
            currentDJ = NULL_KEY;
            djName = "";
            UseFallbackTexture();
            llSetText("🎶 Touch to Login as DJ 🎶", <1,1,1>, 1.0);
            llSetTimerEvent(0.0);
        }
    }

    http_response(key req, integer status, list meta, string body)
    {
        if (req != lastRequestID) return;

        integer s1 = llSubStringIndex(body, profile_key_prefix);
        integer s1l = profile_key_prefix_length;

        if (s1 == -1)
        {
            s1 = llSubStringIndex(body, profile_img_prefix);
            s1l = profile_img_prefix_length;
        }

        if (s1 == -1)
        {
            UseFallbackTexture();
        }
        else
        {
            s1 += s1l;
            key UUID = llGetSubString(body, s1, s1 + 35);
            if (UUID == NULL_KEY)
            {
                UseFallbackTexture();
            }
            else
            {
                llSetTexture(UUID, 3);
            }
        }
    }

    on_rez(integer start_param) { llResetScript(); }
}
