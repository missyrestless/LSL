// Dhyana Writer 2009 


list gInventoryList;

list getInventoryList()
{
    integer i;
    integer n = llGetInventoryNumber(INVENTORY_ALL);
    list result = [];

    for( i = 0; i < n; i++ )
    {
        result += [ llGetInventoryName(INVENTORY_ALL,i) ];
    }
    return result;
}

default
{
    on_rez(integer r)
    {
        llResetScript();
    }
    
    state_entry()
    {
        gInventoryList = getInventoryList();
        llSetText(llGetObjectName() + "\n",<1,1,1>,1);
    }

    touch_start( integer n )
    {
        integer i;
        for( i = 0; i < n; i++ )
        {
            if (llDetectedKey(i) != llGetOwner()) //anyone
            {
                //nothing happens
            }
            else if (llDetectedKey(i) == llGetOwner()) //owner
            {
                llGiveInventoryList(llDetectedKey(i), llGetObjectName(), gInventoryList );
            }
        }
    }

    changed( integer change )
    {
       if ( change == CHANGED_INVENTORY )
           gInventoryList = getInventoryList();
    }
}
