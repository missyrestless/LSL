// Open Other Way -- Rolig Loon -- April 2017
//
// Builders sometimes ask for a door that will open away from you as you approach it,
// think of a bi-swing door in a restaurant kitchen, for example. There are several ways
// to write a script to detect where an av is, relative to a door or wall. This script
// does it by locating the av relative to the door's "default" direction of swing, defined
// in its isFacing function. You can use the script in a linked or a freestanding door.
// If the door is in a linkset, just be sure that it is a child link and that the script
// is in the door itself. As written, the door rotates on its Z axis and will determine
// for itself whether its X dimension is larger or smaller than the Y.
// Other possible geometries are left as a challenge for the reader.
//
// Note: Scripters will recognize a genetic relationship to Void Singer's Simple Hinge Action
// script, which remains the most basic door script in SL. Some things are hard to beat.
//
// This script always opens a door away from the person who touches it, then closes the door later automatically.
// The script may be used in a linked or unlinked door, but must be placed in the door itself.
// If the door is linked, it must be a child link.
//
// It was designed for a prim "cut" door (B:0.125, E:0.625 or B;0.375, E:0.875)
// but could be used for a mesh door hinged on one side.
//
// The script will detect whether the door's X dimension is larger or smaller
// than its Y dimension and adjust accordingly.
//
// When it is installed for the first time, be sure that the door is in its CLOSED rotation.
// NOTE: This is its LOCAL rotation, relative to the root of the linkset,
// so it will not be affected if you move the entire linkset later.

// User parameters ===========

integer gIntSwing  = 90;  // Angular swing of the door, in degrees
float   gfOpenTime = 5.0; // Amount of time before the door closes automatically, in seconds

// ===== Do not mess with anything below here unless you know what you are doing ============

rotation gHomeRot;
float    gfHomeAngle;
integer  giXisBigger;
rotation gRotSwing;
integer  gDir;

integer IsClosed(rotation MyRot) {  // Is the door closed?
    float MyAngle = llRot2Angle(MyRot);
    if (llFabs(MyAngle - gfHomeAngle) < 0.0523599) { // Within 3 degrees of "closed"
        llSetLocalRot(gHomeRot);    // Be sure it's closed now, just in case
        return TRUE;
    } else {
        return FALSE;
    }
}

// Alternate isFacing() with simpler math but untested
// integer isFacing(vector avpos) {
//     vector myPos = llGetPos();
//     rotation myRot = llGetRot();
//     vector facing;
//     vector target = llVecNorm( avpos - myPos);
//     float dp;
// 
//     if(giXisBigger) {
//         facing = llRot2Left(myRot);
//         dp = facing*target;
//     } else {
//         facing = llRot2Fwd( myRot);
//         dp = -(facing*target);//had to reverse the dp when Y axis is bigger to make door swing the right direction
//     }
//     return ( dp > 0 );
// }
//
// Where is the av, relative to the door's default swing direction?
integer isFacing(vector AvPos) {
    float dotP = llRot2Fwd(gHomeRot)*llVecNorm((AvPos - llGetPos())/llGetRot()- llGetLocalPos());
    if (giXisBigger) {
        // The door's X dimension is bigger than its Y dimension
        return (RAD_TO_DEG*llAcos(dotP) < 90.0) ;   // TRUE or FALSE?
    } else {
        // The door's Y dimension is bigger than its X dimension 
        return (RAD_TO_DEG*llAcos(dotP) > 90.0) ;   // TRUE or FALSE?
    }        
}

default {
    state_entry() {
        // First, define the "closed" rotation for the door
        gHomeRot    = llGetLocalRot();
        gfHomeAngle = llRot2Angle(gHomeRot);
        vector Size = llList2Vector(llGetLinkPrimitiveParams(LINK_THIS,[PRIM_SIZE]),0);
        giXisBigger = (Size.x > Size.y);
        // and now, here's the default rotation to apply in swinging the door ....
        gRotSwing = llEuler2Rot( <0.0, 0.0, (float)gIntSwing * DEG_TO_RAD> );
    }
    
    touch_end( integer mum ) {
        if ( IsClosed(llGetLocalRot()) ) { //If the door is closed ...
            gDir = 0;        
            if ( isFacing(llDetectedPos(0)) ) { // Where is the av, relative to the door's default swing direction?
                gDir = 1;
                // Reverse the door's default opening direction
                gRotSwing.s *= -1;
            }
            llSetLocalRot( gRotSwing * llGetLocalRot() ); 
            gRotSwing.s *= -1;  // And reverse direction again, ready for the return swing
            llSetTimerEvent(gfOpenTime);         
        }
    }
    
    timer() {
        // Now reverse the direction of gRotSwing and apply it....
        llSetLocalRot( gRotSwing * llGetLocalRot() );
        if (!gDir) { // If the door just opened in the default direction, we don't need to reverse it yet again
            gRotSwing.s *= -1;
        }
        llSetTimerEvent(0.0); 
    }
}
