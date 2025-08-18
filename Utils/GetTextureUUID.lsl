// Get the texture uuids of a prim
// Drop this script into the Contents of a prim you own
// The script will be automatically removed once it completes

default
{
  state_entry() {
    integer num_faces = llGetNumberOfSides();
    integer face;
    for (face=0; face<num_faces; face++) {
      llOwnerSay("Side " + (string)face + " has texture uuid = " + llGetTexture(face));
    }
    llRemoveInventory(llGetScriptName());
  }
}

