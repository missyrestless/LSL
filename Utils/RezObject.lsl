// To rez an object from a prim's inventory in Second Life, use the llRezObject
// LSL functions in a script within the prim. You'll need to specify the name of
// the object in the inventory, the position where you want to rez it, and other
// parameters like rotation and velocity.
//
// The script must be in a prim that has the object in its inventory.

default
{
    state_entry()
    {
        // The name of the object to rez from the inventory
        string objectName = "My Object";
        // The position to rez the object at (e.g., 5 meters in front of the rezzer)
        vector position = llGetPos() + <5.0, 0.0, 0.0>;
        // The velocity to give the object
        vector velocity = ZERO_VECTOR;
        // The rotation to give the object
        rotation rot = ZERO_ROTATION;
        // The parameter to pass to the object's on_rez event
        integer param = 0;

        llRezObject(objectName, position, velocity, rot, param);
    }
}
