default
{
    touch_start(integer total_number)
    {
        // Query the primitive parameters for the prim type
        list primParams = llGetPrimitiveParams([PRIM_TYPE]);
        
        // The first element in the returned list is always the type flag
        integer primType = llList2Integer(primParams, 0);
        
        // Identify the shape type
        if (primType == PRIM_TYPE_BOX)          llOwnerSay("Type: Box");
        else if (primType == PRIM_TYPE_CYLINDER)   llOwnerSay("Type: Cylinder");
        else if (primType == PRIM_TYPE_PRISM)      llOwnerSay("Type: Prism");
        else if (primType == PRIM_TYPE_SPHERE)     llOwnerSay("Type: Sphere");
        else if (primType == PRIM_TYPE_TORUS)      llOwnerSay("Type: Torus");
        else if (primType == PRIM_TYPE_TUBE)       llOwnerSay("Type: Tube");
        else if (primType == PRIM_TYPE_RING)       llOwnerSay("Type: Ring");
        else if (primType == PRIM_TYPE_SCULPT)     llOwnerSay("Type: Sculpt or Mesh");
        else                                       llOwnerSay("Type: Unknown (" + (string)primType + ")");
    }
}
