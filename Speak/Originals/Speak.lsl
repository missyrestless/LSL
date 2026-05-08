////////////////////////////////////////////////////////////////////
// Please leave any credits intact in any script you use or publish.
// Please contribute your changes to the Internet Script Library at 
// http://www.lslscripts.com  by Ferd Frederix
//
// Script Name: Make_your_product_speak.lsl
// Category: Viewer 2
// Description: Want to make your products talk?  You say you made a GPS for Second life and you need to create dynamic voices?    Here's a script that can dynamically generate and play any text to speech, in a male or female voice, on-the fly.   You can actually talk with a voice by just typing.   There are thousands of used:  a greeter, a vendor announcer, a tour guide talker, carny barker, and for this so inclined a PC Mistress (or Master). 
// Comment: Step 1) Create the root prim 
//
//a. Make  a cube prim.  Create a new script, and replace the contents of that script with this script.  Get the script from the above download link, as the code shown in the HTML are below can cause problems with scripts that contain HTML.
//
//b. Be sure to give the prim a good name.   The name of the prim shows up in the upper right hand corner of Viewer 2 in the media panel.  When a user hears your prim, and wants to mute it, they can find it easily when it has a good name.
//
// Downloaded from : http://www.free-lsl-scripts.com/freescripts.plx?ID=1476
//
// From the Internet LSL Script Database & Library of Second Life™ scripts.
// http://www.free-lsl-scripts.com  by Ferd Frederix
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// Other licenses may be located within the source of this script, 
// in which case the more restrictive license is to take effect
//
////////////////////////////////////////////////////////////////////

integer MENUCHANNEL ;
string Voice = "Female";
string lastname;

Say(string msg)
{
    msg  = llEscapeURL(msg);
    
    string url = "http://secondlife.mitsi.com/cgi/speak2.pl?Voice=" + Voice + "&Message=" + msg;
    
    llSetPrimMediaParams(0,                             // Side to display the media on.
    [
        PRIM_MEDIA_CONTROLS,PRIM_MEDIA_CONTROLS_MINI,
        PRIM_MEDIA_AUTO_SCALE,TRUE,
        PRIM_MEDIA_AUTO_LOOP, FALSE,                   // no looping
        PRIM_MEDIA_AUTO_PLAY,TRUE,                     // Show this page immediately
        PRIM_MEDIA_CURRENT_URL,url,                    // The url currently showing
        PRIM_MEDIA_HOME_URL,"http://secondlife.mitsi.com/cgi/speak2.pl?Message=Hello!",  // The url if they hit 'home'
        PRIM_MEDIA_HEIGHT_PIXELS,400,                  // Height/width of media texture will be
        PRIM_MEDIA_WIDTH_PIXELS,1024,
        PRIM_MEDIA_PERMS_INTERACT,PRIM_MEDIA_PERM_OWNER |PRIM_MEDIA_PERM_GROUP
    ]
    );
}  
 

default
{
    state_entry()
    {
         Say("Hello! Type any message into chat, in any of 58 languages, to hear the message spoken in English");
         llListen(0,"","","");  // change this 0 to any private channel 
                                // if you want to control this with another script
    }
    
    listen(integer channel, string name, key id,string msg)
    {
        Say(msg);
    }
    
   
   
    link_message(integer sender_num,integer num, string str, key d)
    {
        Voice = str;
        Say("The sound is now set to " + Voice);
    }
    
    
    on_rez(integer param)
    {
        llResetScript();
    }
}


// Look for updates at : http://www.free-lsl-scripts.com/freescripts.plx?ID=1476
// __END__


