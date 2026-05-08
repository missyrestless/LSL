
integer time = 10; // default time interval
integer side = 0;  // 0 if linked prim, 1 for front only or ALL_SIDES

integer number;
string name;
integer choice = 0;

startup()
{
  number = llGetInventoryNumber(INVENTORY_TEXTURE);
  number -= 1;
  name = llGetInventoryName(INVENTORY_TEXTURE, choice);
  if (name != "")
  {
    llSetTexture(name, side);
    choice = choice + 1;
  }
}

default
{
  on_rez(integer start_param)
  {
    llResetScript();
  }

  state_entry()
  {
    llMessageLinked(LINK_THIS, time, "timerinterval", llGetOwner());
    llSetTimerEvent(time);
    startup();
  }

  link_message(integer sender_num, integer num, string str, key id)
  {
    if (str == "timernumber") // from main script
    {
      time = num;
      llOwnerSay("Timer interval now set to " + (string)time + " seconds.");
      llSetTimerEvent(time);
    }
    else if (str == "resetall")
    {
      llResetScript();
    }
  }

  timer()
  {
    name = llGetInventoryName(INVENTORY_TEXTURE, choice);
    if (name != "")
    {
      llSetTexture(name, side);
    }
    if (choice < number)
    {
      choice = choice + 1;
    }
    else
    {
      choice = 0;
    }
  }

  changed(integer change)
  {
    llSleep(0.5);
    if (change & CHANGED_INVENTORY)
    {
      startup();
    }
  }
}
