// A go-Physical+Phantom Sliding Door by Omei Qunhua
// with Auto-computation of movement axis and distance
// To avoid problems, the script ignores touches while the door is moving

vector     gHome;               // Position of the door in its initial closed position
rotation   gRot;                // The initial rotation of the door prim
vector     gOffset;             // This will be populated with the move distance stored in the appropriate axis position
integer    AUTO_CLOSE_TIME = 0; // Can be zero if no auto-close is desired

StartMove(vector Target) {
    // Set the door PHANTOM and PHYSICAL and start moving it
    llMoveToTarget(Target, 3);             // Do this first, to avoid the door dropping
    llSetStatus(STATUS_PHANTOM, TRUE);
    llSetStatus(STATUS_PHYSICS, TRUE);
    llSetTimerEvent(5);                    // Start a timer. We will end the move after this time.
}

EndMove(vector Target) {
    // Return the door to non-phantom, non-physical and do a final confirmatory move
    llSetTimerEvent(0);
    llSetStatus(STATUS_PHYSICS, FALSE);
    llSetStatus(STATUS_PHANTOM, FALSE);
    llSetPrimitiveParams([ PRIM_POSITION, Target, PRIM_ROTATION, gRot ]);
}

default {
    state_entry() {
        gRot = llGetRot();
        gHome = llGetPos();
        vector Scale = llGetScale();
        // Find the middle sized dimension of the door prim
        // This determines the axis to move on, and the distance to move
        list lx = llListSort( [Scale.x, <1,0,0>, Scale.y, <0,1,0>, Scale.z, <0,0,1> ], 2, TRUE ); 
        gOffset = llList2Vector(lx, 3) * llList2Float(lx, 2);  // Apply the distance to move to the appropriate dimension
    }

    touch_end(integer total_number) {
        state opening;
    }
}

state opening {    // In this state, the door is in process of opening
    state_entry() {
        StartMove(gHome + gOffset * gRot);
    }

    timer() {
        EndMove(gHome + gOffset * gRot);
        state open;
    }
}

state open {       // The door is fully open
    state_entry() {
        llSetTimerEvent(AUTO_CLOSE_TIME);    // Close the door after this time (or not, if value is zero)
    }

    // We will close the door either if it's touched while fully open, or after a time
    touch_end(integer num) {
        state closing;
    }

    timer() {
        state closing;
    }
}

state closing {       // State for when the door is in the process of closing
    state_entry() {
        StartMove(gHome);
    }

    timer() {
        EndMove(gHome);
        state default;
    }
}
