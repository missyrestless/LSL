// Smoothly slide an object the length of itself along its local X-axis
// Written 05-October-2026 by Missy Restless <missyrestless@gmail.com>

integer Moved = FALSE; // Track toggle state
float   distance;
vector  size;

default {
    state_entry() {
        llSetLinkPrimitiveParamsFast(LINK_THIS, [PRIM_PHYSICS_SHAPE_TYPE, PRIM_PHYSICS_SHAPE_CONVEX]);
        // Get the object's size (length)
        size = llGetScale();
        // Define the distance to move (using the X dimension of its size)
        distance = size.x;
    }

    touch_start(integer total_number) {
        // If already moved, reverse the direction
        if (Moved) {
            distance = -distance;
        }
        
        // 3. Calculate the local translation vector
        vector local_offset = <distance, 0.0, 0.0>;
        
        // 4. Convert local offset to global coordinates based on current rotation
        vector global_offset = local_offset * llGetRot();
        
        // 5. Define the movement keyframe: [offset vector, rotation, duration in seconds]
        float duration = 1.0; // Adjust this number to make it slide faster or slower
        list keyframe = [global_offset, ZERO_ROTATION, duration];
        
        // 6. Trigger the smooth motion
        llSetKeyframedMotion(keyframe, []);
        
        // Toggle the state tracker
        Moved = !Moved;
    }
}
