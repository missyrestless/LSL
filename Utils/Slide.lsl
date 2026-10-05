// Smoothly slide an object the length of itself along its local X-axis
//
// Written 05-October-2026 by Missy Restless <missyrestless@gmail.com>
//
// Sets the physics shape of the object to Convex Hull
// Sets object to phantom during movement

integer moved   = FALSE; // Track toggle state
integer phantom = FALSE;
float   distance;
vector  size;

default {
    state_entry() {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_CONVEX]);
        // Get the object's size (length)
        size = llGetScale();
        // Define the distance to move (using the X dimension of its size)
        distance = size.x;
        phantom  = llGetStatus(STATUS_PHANTOM);
    }

    touch_start(integer total_number) {
        // If already moved, reverse the direction
        if (moved) {
            distance = -distance;
        }
        
        // Calculate the local translation vector
        vector local_offset = <distance, 0.0, 0.0>;
        
        // Convert local offset to global coordinates based on current rotation
        vector global_offset = local_offset * llGetRot();
        
        // Define the movement keyframe: [offset vector, rotation, duration in seconds]
        float duration = 1.0; // Adjust this number to make it slide faster or slower
        list keyframe = [global_offset, ZERO_ROTATION, duration];
        
        llSetStatus(STATUS_PHANTOM, TRUE);

        // Trigger the smooth motion
        llSetKeyframedMotion(keyframe, []);
        
        // Toggle the state tracker
        moved = !moved;
        
        llSetStatus(STATUS_PHANTOM, phantom);
    }
}
