default
{
    state_entry()
    {
        // Get the name of the first texture in the prim's inventory
        string texName = llGetInventoryName(INVENTORY_TEXTURE, 0);
        
        if (texName != "")
        {
            // Request the texture's UUID (Asset Key)
            key texUUID = llGetInventoryKey(texName);
            
            if (texUUID != NULL_KEY)
            {
                llOwnerSay("UUID for '" + texName + "': " + (string)texUUID);
                
                // Self-delete so the script doesn't stay in the prim
                llRemoveInventory(llGetScriptName());
            }
            else
            {
                llOwnerSay("Error: Cannot read UUID. Ensure you have full permissions.");
            }
        }
        else
        {
            llOwnerSay("Error: No texture found in the prim's inventory.");
        }
    }
}