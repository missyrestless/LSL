// While there is no "standard" for names, it's a good idea to take some steps to prevent against other scripts accidentally overwriting your data.
// Since the datastore is shared among the entire linkset, one way to avoid name conflicts is to include the prim's UUID in the data pair's name.
// This example also monitors for llLinksetDataReset/unlinks and refreshes the datastore in response, which is usually good practice if you want to keep your data!

key this_uuid;
string lsd_data;

default
{
    state_entry()
    {
        this_uuid = llGetKey(); // Save the current key into this_uuid for checking later
        lsd_data = "bar"; // Store the data locally so it can be rewritten if the datastore gets erased for whatever reason
        llLinksetDataWrite((string)llGetKey() + "-foo", lsd_data); // Write the data
    }
    on_rez(integer start_param)
    {
        if (llGetKey() != this_uuid)
        {
            // Prim UUID has changed!
            // This should always be the case when on_rez is called, but is included here for clarity.
            llLinksetDataWrite((string)llGetKey() + "-foo", llLinksetDataRead((string)this_uuid + "-foo")); // Read the data from the last prim UUID's pair and write it into this prim UUID's pair
            // Note that you could also just write the lsd_data string instead of calling llLinksetDataRead, but this method is theoretically a little more robust if you expect other scripts to manipulate the data.
            llLinksetDataDelete((string)this_uuid + "-foo"); // Erase the original data to free up memory
            this_uuid = llGetKey(); // Update the UUID variable to the new UUID
        }
    }
    linkset_data(integer action, string name, string value)
    {
        if (action == LINKSETDATA_UPDATE || action == LINKSETDATA_DELETE)
        {
            if (name == (string)llGetKey() + "-foo")
            {
                // Somebody else wrote to our pair - we'll just save it in case we need it later, but you could re-write the original data instead if desired.
                lsd_data = value; // Note that in the case of LINKSETDATA_DELETE, value will be an empty string (""), which may or may not be how you want to handle that case
            }
        }
        else if (action == LINKSETDATA_RESET) 
        {
            // Linkset datastore has been reset!
            llLinksetDataWrite((string)llGetKey() + "-foo", lsd_data); // Write the lsd_data string into this prim UUID's pair - in this case we can't use llLinksetDataRead because the datastore is empty
        }
    }
    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            // Linkset has changed!
            // Generally, this can happen for a few reasons (see Caveats above), including when an avatar sits on the object. In certain circumstances, this resets the datastore.
            // However, since the linkset data functions are very quick, it is easier to just write the data on every change to be safe for this example whether or not the datastore was reset.
            llLinksetDataWrite((string)llGetKey() + "-foo", lsd_data); // Write the lsd_data string into this prim UUID's pair - in this case we can't use llLinksetDataRead because the datastore might be empty
        }
    }
}
