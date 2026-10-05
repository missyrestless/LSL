// Innula Zenovka posted this in community forums
//
// There's no ready way to vary the door speed when you use llSetRot or
// llSetLinkPrimitiveParams* to change the rotation. The simulator simply snaps
// the door into the new rotation and interpolates the movement as best it can.
//
// There are various work-rounds for this. You could move the door in a very fast loop,
// a degree or so at a time, but I think I'd look for a different door in that case,
// one that has its pivot point in the center, and then use llTargetOmega to move the
// door at the desired speed and, on a timer,  llSetLocalRot or llSetLinkPPFast
// to snap it into place when llTargetOmega had done its stuff.
//

rotation rotSwing;
vector   vOffset;

default {
    state_entry() {
        rotSwing    = llEuler2Rot(<0.0,0.0,90.0>*DEG_TO_RAD); // 90 degrees on the z axis
        vector size = llGetScale();

        // open away from someone standing in front of face 2
        // that is, in front of the prim, hinged on the left
        vOffset     = <(size.x*-0.5),(size.y*-0.5),0.0>;
    }

    touch_start(integer total_number) {
        list     l = llGetPrimitiveParams([PRIM_POS_LOCAL,PRIM_ROT_LOCAL]);
        vector   v = llList2Vector(l,0);
        rotation r = llList2Rot(l,1);
        llSetPrimitiveParams([PRIM_POS_LOCAL,v+(vOffset-vOffset * rotSwing)*r, PRIM_ROT_LOCAL,rotSwing*r]);
        rotSwing.s *= -1;
    }
}
