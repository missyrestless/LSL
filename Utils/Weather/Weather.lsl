// Weather written by Spood Udimo
// See http://www.spoodudimo.com/2015/07/using-lsl-scripting-to-dynamically.html
//
// Modified by Missy Restless <missyrestless@gmail.com> 13-Aug-2026
//
// To use the script:
//
// 1. Create a prim
// 2. Right click the prim and select Edit
// 3. Drag and drop this script into the Contents tab of the Edit window
// 4. Close the Edit window
// 5. Click the prim
//
// You must be using an RLV capable viewer with RLV enabled.
// Only the owner of the prim can see the effect as RLV is a client side
// server extension and Windlight changes require owner level access.

integer listener=0;
key user;
integer channel=0;
float bluedensityb_Begin=0.0;
float bluedensityb_Finish=0.98;
float bluedensityb_Current=0.0;
float bluedensityb_Step=0;
float TICK_Setting_Original = 6.0;
float TICK_Transform = 5.0;
float TICK_Transform_Incr = 0.15;
float TICK_Setting_New = 10.0;
float TICK_Transform_ReturnTo = 4.0;
float TICK_Listener_Removal = 60;
float Transform_Direction=1.0;
string PRESET="Bristol";
string PREVIOUS_State="";

default
{
  state_entry() {
    if(channel==0) channel = (integer)("0x" + llGetSubString( (string) llGetKey(), -7, -1) );
  }

  touch_start(integer num_detected) {
    llListenRemove(listener);
    user = llDetectedKey(0);
  }

  touch_end(integer num_detected) {
    listener = llListen(channel, "", user, "");
    llDialog(user, "\nStart the Windlight transformation sequence?", ["Yes", "No" ] , channel);
    llSetTimerEvent(TICK_Listener_Removal);
  }

  listen(integer chan, string name, key id, string msg) {
    if (msg == "Yes") {
      llOwnerSay("@setenv_preset:"+PRESET+"=Force"); // Start from a preset
      llOwnerSay("@getenv_bluedensityb="+(string)channel); // Get the value of bluedensityb
    } else if (msg == "No") {
      llOwnerSay("Stopping Sequence...");
      llOwnerSay("@setenv_daytime:-1=Force");
      llListenRemove(listener);
    } else {
      bluedensityb_Begin = (float)msg;
      // A step is the distance between the begining value and end value divided by the total ticks in time.
      bluedensityb_Step = (bluedensityb_Finish - bluedensityb_Begin)/(TICK_Transform*(1/TICK_Transform_Incr));
      state Setting_Original;
    }
  }

  timer() {
    llListenRemove(listener);
    llSetTimerEvent(0.0);
  }

  state_exit() {
    llListenRemove(listener);
    llSetTimerEvent(0.0);
  }
}

state Setting_Original
{
  state_entry() {
    llSetTimerEvent(TICK_Setting_Original);
  }

  timer() {
    state Transform;
  }

  touch_end(integer num_detected) {
    PREVIOUS_State="Setting_Original";
    user = llDetectedKey(0);
    state Pause;
  }

  state_exit() {
    bluedensityb_Current = bluedensityb_Begin;
    llSetTimerEvent(0.0);
  }
}

state Transform
{
  state_entry() {
    llSetTimerEvent(TICK_Transform_Incr);
  }

  timer() {
    llOwnerSay("@setenv_bluedensityb:"+(string)bluedensityb_Current+"=force");
    if ((Transform_Direction==1.0) && (bluedensityb_Current>=bluedensityb_Finish)) state Setting_New;
    if ((Transform_Direction==-1.0) && (bluedensityb_Current<=bluedensityb_Begin)) state Setting_Original;
    bluedensityb_Current += (Transform_Direction * bluedensityb_Step);
  }

  touch_end(integer num_detected) {
    PREVIOUS_State="Transform";
    user = llDetectedKey(0);
    state Pause;
  }

  state_exit() {
    Transform_Direction*= -1;
    llSetTimerEvent(0.0);
  }
}

state Setting_New
{
  state_entry() {
    llSetTimerEvent(TICK_Setting_New);
  }

  timer() {
    state Transform;
  }

  touch_end(integer num_detected) {
    PREVIOUS_State="Setting_New";
    user = llDetectedKey(0);
    state Pause;
  }

  state_exit() {
    bluedensityb_Current = bluedensityb_Finish;
    llSetTimerEvent(0.0);
  }
}

state Pause
{
  state_entry() {
    listener = llListen(channel, "", user, "");
    llDialog(user, "\nThe Windlight transformation is currently running.\nDo you want to stop it?", ["Yes", "No" ] , channel);
    llSetTimerEvent(TICK_Liste_Remneroval);
  }

  listen(integer chan, string name, key id, string msg) {
    if (msg == "No") {
      if (PREVIOUS_State=="Setting_Original") state Setting_Original;
      if (PREVIOUS_State=="Transform") state Transform;
      if (PREVIOUS_State=="Setting_New") state Setting_New;
    } else {
      llOwnerSay("Stopping Transformation...");
      llOwnerSay("@setenv_daytime:-1=Force");
      state default;
    }
  }

  timer() {
    llOwnerSay("Stopping Transformation...");
    llOwnerSay("@setenv_daytime:-1=Force");
    state default;
  }

  state_exit() {
    llListenRemove(listener);
    llSetTimerEvent(0.0);
  }
}
