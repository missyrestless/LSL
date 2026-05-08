// Removes the hover text of a prim
// Drop this script into the Contents of a prim
// The script will remove itself from the prim when done

default
{
    state_entry()
    {
        llSetText("", < 1.0, 1.0, 1.0>, 1.0);
        llRemoveInventory(llGetScriptName());
    }
}
