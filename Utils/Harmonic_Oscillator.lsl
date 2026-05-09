// Script Name: Harmonic_Oscillator_motion.lsl
// Harmonic oscillator motion in 12 Key Frames,
// using the new llSetKeyframedMotion command
//
// Will oscillate a prim along a straight line in space
// Only the first half period is computed, the second is the first in reverse
// If the prim is moved, rotated or scaled the script must be reset to update
// the motion
//
// This work uses content from the Second LifeÂ® Wiki.
// Copyright © 2007-2009 Linden Research, Inc.
// Licensed under the Creative Commons Attribution-Share Alike 3.0 License
//
// Harmonic oscillator motion by Dora Gustafson, Studio Dora 2012
// will oscillate a prim along a straight line in space
// only the first half periode is computed, the second is the first in reverse
 
float phase=PI;
vector amplitude=< 0.0, 0.0, 2.0>; // amplitude and direction for oscillation
float Hperiode=2.0; // half periode time S
float steps=12; // number of Key Frames for a half periode
float step=0.0;
list KFMlist=[];
vector U;
vector V;
integer osc=TRUE;
vector basePos;
 
default
{
    state_entry()
    {
        llSetMemoryLimit( llGetUsedMemory()+0x1000);
        llSetPrimitiveParams([PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_CONVEX]);
        basePos = llGetPos();
        float dT = Hperiode/steps;
        dT = llRound(45.0*dT)/45.0;
        if ( dT < 0.11111111 ) dT = 0.11111111;
        U = amplitude*llCos( phase);
        while ( step < steps )
        {
            step += 1.0;
            V = amplitude*llCos( PI*step/steps + phase);
            KFMlist += [V-U, dT];
            U = V;
        }
    }
    touch_start( integer n)
    {
        llSetKeyframedMotion( [], []);
        llSleep(0.2);
        llSetRegionPos( basePos);
        llSetPos( basePos);
        if ( osc ) llSetKeyframedMotion( KFMlist, [KFM_DATA, KFM_TRANSLATION, KFM_MODE, KFM_PING_PONG]);
        osc = !osc;
    }
    on_rez( integer n) { llResetScript(); }
}
