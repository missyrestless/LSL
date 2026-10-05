// Smoothly slide an object the length of itself along its local X-axis
// Written 05-October-2026 by Missy Restless <missyrestless@gmail.com>

integer Moved = FALSE; // Track toggle state

default {
    touch_start(integer total_number) {
        // 1. Get the object's size (length)
        vector size = llGetScale();
        
        // 2. Define the distance to move (using the X dimension of its size)
        float distance = size.x;
        
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
