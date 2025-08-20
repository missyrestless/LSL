////////////////////////////////////////////////////////////////////
// Please leave any credits intact in any script you use or publish.
// Please contribute your changes to the Internet Script Library at 
// http://www.free-lsl-scripts.com  
//
// Script Name: Make_your_product_speak.lsl
// Category: Viewer 2
// Description: Want to make your products talk? You say you made a GPS for
// Second life and you need to create dynamic voices? Here's a script that
// can dynamically generate and play any text to speech, in a male or female
// voice, on-the fly. You can actually talk with a voice by just typing.
// There are thousands of used:  a greeter, a vendor announcer, a tour guide
// talker, carny barker, and for this so inclined a PC Mistress (or Master). 
// Comment: Male Button:
//
// Downloaded from : http://www.free-lsl-scripts.com/freescripts.plx?ID=1476
//
// From the Internet LSL Script Database & Library of Second Life™ scripts.
// http://www.free-lsl-scripts.com  by Ferd Frederix
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the license information included in each script
// by the original author.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
//
//
////////////////////////////////////////////////////////////////////
default
{
    touch_start(integer total_number)
    {
       llMessageLinked(LINK_SET,0,"Male","");
       llSetAlpha(0.0,ALL_SIDES);
       llSleep(0.5);
       llSetAlpha(1.0,ALL_SIDES);
    }
}


// Look for updates at : http://www.free-lsl-scripts.com/freescripts.plx?ID=1476
// __END__

