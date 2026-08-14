// Multi-Page Texture Selector 
// Omei Qunhua  April 2014

list       listFullNames;            // List of inventory textures
list       listBriefNames;           // List of abbreviated texture names for dialog buttons

integer    Page;                     // Current dialog page number (counting from zero)
integer    MaxPage;                  // Highest page number (counting from zero)
integer    dialogChannel;            // Channel used for dialog communications.
key        User;                     // Current user accessing the dialogs

BuildDialogPage(key user) {
    integer TotalChoices = (listBriefNames != [] );        // get length of texture list

    // set up scrolling buttons if needed
    list buttons = [ "<<", " ", ">>" ];
    
    integer ChoicesPerPage = 9;
    if (TotalChoices < 13) {
        buttons = [];
        ChoicesPerPage = 12;
    }
    // Compute number of menu pages that will be available
    MaxPage = (TotalChoices - 1) / ChoicesPerPage;
    // Build a dialog menu for current page for given user
    integer start = ChoicesPerPage * Page;       // starting offset into action list for current page
    // 'start + ChoicesPerPage -1' might point beyond the end of the list -
    // - but LSL stops at the list end, without throwing a wobbly
    buttons += llList2List(listBriefNames, start, start + ChoicesPerPage - 1);
    llDialog(user, "\nPage " + (string) (Page+1) + " of " + (string) (MaxPage + 1) + "\n\nChoose an item", buttons, dialogChannel);
    llSetTimerEvent(30);              // If no response in time, return to 'ready' state
}

default
{
    touch_end(integer total_number) {
        // Compute a negative communications channel based on prim UUID
        dialogChannel = 0x80000000 | (integer) ( "0x" + (string) llGetKey() );
        User = llDetectedKey(0);
        integer count = llGetInventoryNumber(INVENTORY_TEXTURE);
        string name;
        while (count--) {
            name = llGetInventoryName(INVENTORY_TEXTURE, count);
            listFullNames += name;
            listBriefNames += llGetSubString(name, 0, 23);
        }

        state busy;
        // Changing state sets the application to a busy condition while one user is selecting from the dialogs
        // In the event of multiple 'simultaneous' touches, only one user will get a dialog
    }
}

state busy
{
    state_entry() {
        llListen(dialogChannel, "", User, "");                // This listener will be used throughout this state
        Page = 0;
        BuildDialogPage(User);                        // Show  Page 0 dialog to current user
    }

    listen (integer chan, string name, key id, string msg) {
        integer index;
        string  name2;
        if (msg == "<<" || msg == ">>") {
            if (msg == "<<")        --Page;              // Page back
            if (msg == ">>")        ++Page;              // Page forward
            if (Page < 0)          Page = MaxPage;     // cycle around pages
            if (Page > MaxPage)   Page = 0;
            BuildDialogPage(id);
            return;
        }
        if (msg != " ") {
            // User has selected a texture from the menu
            index = llListFindList(listBriefNames, [msg]);
            name2 = llList2String(listFullNames, index);
            llRegionSayTo(id, 0, "You chose texture <" + name2 + ">");
            llSetTexture(name2, ALL_SIDES);
        }
        llResetScript();
    }

    timer() {
        llRegionSayTo(User, 0, "Too slow, menu cancelled");
        llResetScript();
    }
}
