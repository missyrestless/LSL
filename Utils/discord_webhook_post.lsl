
string  LSD_KEY       = "discord_webhook";   // linkset data key
integer MENU_CHAN     = -91827364;          
integer INPUT_CHAN    = -91827365;          
float   LISTEN_TTL    = 60.0;                
integer gMenuListen   = -1;
integer gInputListen  = -1;
key     gUser         = NULL_KEY;

sendDiscord(string msg)
{
    string url = llLinksetDataRead(LSD_KEY);
    if (url == "")
    {
        llOwnerSay("[Discord] No URL set. Touch the prim and choose 'Discord' first.");
        return;
    }

    string escaped = msg;
    escaped = llDumpList2String(llParseStringKeepNulls(escaped, ["\\"], []), "\\\\");
    escaped = llDumpList2String(llParseStringKeepNulls(escaped, ["\""], []), "\\\"");
    escaped = llDumpList2String(llParseStringKeepNulls(escaped, ["\n"], []), "\\n");
    escaped = llDumpList2String(llParseStringKeepNulls(escaped, ["\r"], []), "\\r");
    escaped = llDumpList2String(llParseStringKeepNulls(escaped, ["\t"], []), "\\t");

    string body = "{\"content\":\"" + escaped + "\"}";

    llHTTPRequest(url,
        [ HTTP_METHOD,     "POST",
          HTTP_MIMETYPE,   "application/json",
          HTTP_VERIFY_CERT, TRUE,
          HTTP_BODY_MAXLENGTH, 16384 ],
        body);
}

showMenu(key user)
{
    gUser = user;

    if (gMenuListen != -1) llListenRemove(gMenuListen);
    gMenuListen = llListen(MENU_CHAN, "", user, "");
    llSetTimerEvent(LISTEN_TTL);

    string current = llLinksetDataRead(LSD_KEY);

    llDialog(user,
        "\n[Discord Webhook Setup]\n\nChoose an option:",
        ["Discord", "Test", "Clear", "Check", "Close"],
        MENU_CHAN);
}

// ------------------------------------------------------------
default
{
    state_entry()
    {
        llOwnerSay("[Discord] Ready. Touch to configure.");
    }

    touch_start(integer n)
    {
        showMenu(llDetectedKey(0));
    }

    listen(integer chan, string name, key id, string msg)
    {
        if (chan == MENU_CHAN)
        {
            if (msg == "Discord")
            {
                if (gInputListen != -1) llListenRemove(gInputListen);
                gInputListen = llListen(INPUT_CHAN, "", id, "");
                llSetTimerEvent(LISTEN_TTL);

                llTextBox(id,
                    "\nPaste your Discord webhook URL into box)",
                    INPUT_CHAN);
            }
            else if (msg == "Test")
            {
                sendDiscord("Test message from Second Life **" + llGetObjectName() + "** (owner: " + llKey2Name(llGetOwner()) + ")");
                llRegionSayTo(id, 0, "[Discord] Test message sent.");
            }
            else if (msg == "Clear")
            {
                llLinksetDataDelete(LSD_KEY);
                llRegionSayTo(id, 0, "[Discord] Webhook cleared.");
            }
            else if (msg == "Check")
            {
                llRegionSayTo(id, 0, "[Discord] Url is: " + llLinksetDataRead(LSD_KEY));
            }
            else if (msg == "Close")
            {
                // do nothing
            }
        }

        else if (chan == INPUT_CHAN)
        {
            string url = llStringTrim(msg, STRING_TRIM);
            integer rc = llLinksetDataWrite(LSD_KEY, url);
            if (rc == LINKSETDATA_OK)
            {
                llRegionSayTo(id, 0, "[Discord] Webhook saved.");
            }
            else
            {
                llRegionSayTo(id, 0, "[Discord] Save failed (code " + (string)rc + ").");
            }

            if (gInputListen != -1)
            {
                llListenRemove(gInputListen);
                gInputListen = -1;
            }
        }
    }

    http_response(key req, integer status, list meta, string body)
    {
        if (status == 204 || status == 200)
        {
            // success - silent
        }
        else
        {
            llOwnerSay("[Discord] HTTP " + (string)status + ": " + body);
        }
    }

    timer()
    {
        if (gMenuListen  != -1) { llListenRemove(gMenuListen);  gMenuListen  = -1; }
        if (gInputListen != -1) { llListenRemove(gInputListen); gInputListen = -1; }
        llSetTimerEvent(0.0);
    }

    changed(integer change)
    {
        if (change & CHANGED_OWNER) llResetScript();
    }
}
