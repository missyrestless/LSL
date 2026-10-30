// Based on public domain implementation by Trimming Hedges

integer owneronly = 0;
key owner;

default
{
    state_entry() {
        owner = llGetOwner(); 
        llSetText("", <0.0,1.0,0.0>, 1);       
    }

    touch_start(integer total_number) {
        integer i;
        for (i=0;i<total_number;i++) {
            key target = llDetectedKey(i);
        
            // person clicking isn't owner and owneronly is set;
            if ( (target != owner) && (owneronly == 1) ) {
                llInstantMessage(target,"Sorry, only the owner is allowed to get my contents.");
                return;
            }
            // Pick the inventory types to give:
            // INVENTORY_BODYPART  INVENTORY_CLOTHING  INVENTORY_LANDMARK  INVENTORY_NOTECARD
            // INVENTORY_OBJECT  INVENTORY_SCRIPT  INVENTORY_SOUND  INVENTORY_TEXTURE
            list inventory_types = [INVENTORY_NOTECARD];
            integer inventory_count = llGetListLength(inventory_types);
            integer j;
            integer k;
            integer type;
            integer typecount;
            //string myname = llGetScriptName();Un comment to set for dynamic naming script
            string myname = "GiveNotecard";
            string objectname;

            for (j=0; j<inventory_count;j++) {
                type = llList2Integer(inventory_types,j); // get the next inventory type from the list
                typecount = llGetInventoryNumber(type);  // how many of that kind of inventory is in the box?
                if (typecount > 0) {
                    for (k=0; k<typecount;k++) {
                        objectname = llGetInventoryName(type,k);
                        // don't give self out so the user doesn't get fifty thousand copies.
                        if (objectname != myname) {
                            llGiveInventory(target,objectname);
                        }
                    }
                }            
            }
        }
    }
}
