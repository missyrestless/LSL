// ~ PROFILE PROJECTOR v5.4.3 by Debbie Trilling ~
// - Modified for HUD use by Ariane Brodie
 
// *** This script cycles through AVs from a crowd & then displays their name and
// profile picture as texture on a hud prim***
 
// Free to use as you wish by under condition that the title and this introduction remain in place,
// and that due credit continues to be given to Moriash Moreau, Jana Kamachi and Solar Alter, and
// Debbie Trilling.
 
// TOUCH will automatically move your camera to the persons avatar, then revert to nrmal after a few seconds
// As this is a private HUD, exclude list and listen commands are not needed. To disable, just unwear it.
 
 
//************************
// GENERAL PARAMETERS
//************************
 
// how often in seconds the sensor fires
float RepeatTime = 35.00;
 
// sensor range in meters. Maximum 96m but in practice 40m because of camera move limitations
float Range = 40.00;
 
// texture palette of UUID's. The one included is simply a transparent texture so the HUD is invisible when no one is in range
list DefaultTexturePalette = ["34f7488f-202c-6f2e-3873-c6baf6666138"];
 
// sets whether the DefaultTexturePalette will be used to texture/project when the toy is switched OFF. 'TRUE' to texture/project; 'FALSE' to have no texturing/projection when off
integer EmployDefaultTexture = TRUE;

 
 
//************************
// PRIM TEXTURE PARAMETERS
//************************
 
// set to TRUE to texture the prim with the profile picture on ALL_SIDES
integer TexturePrim = TRUE;
 
// the following 'Prim*' parameters effect the prim only if ("EmployDefaultTexture = FALSE") OR ("EmployDefaultTexture = TRUE" and "TexturePrim=FALSE")
// if TexturePrim = TRUE then the prim is automatically set to solid blank white no shiny with full bright as this is usually the best surface to display the profile picture
 
// set the degree of 'shininess' to apply to the prim "0" = None, "1" = Low, "2" = medium, "3" = high
integer PrimShine = 0;
 
 
//************************
// FLOATING TEXT PARAMETERS
//************************
// set to TRUE for floating text above the prim; FALSE to disable the floating text
integer ApplyFloatingText = TRUE;
 
// set the text to be displayed at first. This will change to name of avatar pic being displayed.
string FloatingText = "Profile Picture HUD";
 
// set the text colour
vector FloatingTextColour = <1.0,1.0,1.0>;
 
// set the text alpha
float FloatingTextAlpha = 1.0;


//************************
// ** DO NOT CHANGE BELOW THIS LINE **
//************************
 
 
 
 
integer Power = FALSE;
integer counter = 0;
key AVKey = "";
key DetectedUser = "";
key ObjectOwner = "";
key LastTexture = "";
string OwnerName = "";
vector pos;
rotation rot;
vector rotz;
integer permissions=FALSE;
vector position;
rotation facing;
 
StopCamera()
{
    if(permissions&PERMISSION_CONTROL_CAMERA)
            llSetCameraParams([CAMERA_ACTIVE, FALSE]);
} 
  
SetFloatingText()
{
    if (ApplyFloatingText)
    {
        llSetText(FloatingText, FloatingTextColour, FloatingTextAlpha);
    }
    else
    {
        llSetText("",<1.0,1.0,1.0>,0.0);
    }
}
 
 
ApplyPrimSurface()
{
    // putting texture on the prim, let's make sure it is solid white, blank. full bright
    llSetPrimitiveParams([PRIM_FULLBRIGHT, ALL_SIDES, TRUE, PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 1.0, PRIM_BUMP_SHINY, ALL_SIDES, 0, 0 ]);
}
 
StartUp()
{
    Power = TRUE;
    llSensorRepeat("",NULL_KEY,AGENT,Range,PI,RepeatTime);
    llOwnerSay("\nThe Profile Camera is now ready. Scanning for people nearby. Please wait...");
}
 
ApplyDefaultTexture()
{
    ApplySelectedTexture((key)llList2String(DefaultTexturePalette, (integer)llFrand((float)llGetListLength(DefaultTexturePalette))));
}
 
 
string DeriveName(string messagecapture)
{
    string DerivedName = llGetSubString(llStringTrim(messagecapture,STRING_TRIM),8,llStringLength(llStringTrim(messagecapture,STRING_TRIM)));
    return DerivedName;
}
 
 
ApplySelectedTexture(key texture)
{
    if (TexturePrim)
    {
        llSetTexture(texture, ALL_SIDES);
    }
}
 
default
{
 
    on_rez(integer start_param)
    {
        // reset script on rez
        llResetScript();
    }
 
    changed( integer change )
    {
        if(change & CHANGED_OWNER )
        {
            // reset script on change of owner
            llResetScript();
        }
    }
 
    state_entry()
    {
        //initialise system
        SetFloatingText();
        StartUp();
    }
 
    touch_start(integer total_number)
    {
        llRequestPermissions(llGetOwner(), PERMISSION_CONTROL_CAMERA);
    }
    
    run_time_permissions(integer perm) {
        permissions = perm;
        if ((perm & PERMISSION_CONTROL_CAMERA) == PERMISSION_CONTROL_CAMERA) {
        llSetCameraParams([
        CAMERA_ACTIVE, 1, // 1 is active, 0 is inactive
        CAMERA_BEHINDNESS_ANGLE, 0.0, // (0 to 180) degrees
        CAMERA_BEHINDNESS_LAG, 0.0, // (0 to 3) seconds
        CAMERA_DISTANCE, 0.0, // ( 0.5 to 10) meters
        CAMERA_FOCUS, pos, // region relative position
        CAMERA_FOCUS_LAG, 0.0 , // (0 to 3) seconds
        CAMERA_FOCUS_LOCKED, TRUE, // (TRUE or FALSE)
        CAMERA_FOCUS_THRESHOLD, 0.0, // (0 to 4) meters
//        CAMERA_PITCH, 80.0, // (-45 to 80) degrees
        CAMERA_POSITION, pos + rotz, // region relative position
        CAMERA_POSITION_LAG, 0.0, // (0 to 3) seconds
        CAMERA_POSITION_LOCKED, TRUE, // (TRUE or FALSE)
        CAMERA_POSITION_THRESHOLD, 0.0, // (0 to 4) meters
        CAMERA_FOCUS_OFFSET, ZERO_VECTOR // <-10,-10,-10> to <10,10,10> meters

        ]);
        }
    }
 
 
    sensor(integer total_number)
    {
        // save the AV key in case it is needed for a 'ShoutOut'
        counter++;
        if(counter >= total_number)
            counter = 0;
        integer pick = counter;
        AVKey = llDetectedKey(pick);
        FloatingText = llDetectedName(pick);
        pos = llDetectedPos(pick); 
        rot = llDetectedRot(pick);
        rotz = llRot2Fwd(rot);
            rotz.x = rotz.x * 2;
            rotz.y = rotz.y * 2;
            rotz.z = 1;
        StopCamera();
        SetFloatingText();
        // core code by Jana Kamachi and Solar Alter. Adapted to suit by Debbie Trilling
        string URL_RESIDENT = "http://world.secondlife.com/resident/";
        llHTTPRequest( URL_RESIDENT + (string)AVKey,[HTTP_METHOD,"GET"],"");
    }
 
 
    no_sensor()
    {
        FloatingText = "";
        StopCamera();
        SetFloatingText();
        ApplyDefaultTexture();
    }
 
 
    http_response(key req,integer stat, list met, string body)
    {
        // core code by Jana Kamachi and Solar Alter. Adapted to suit by Debbie Trilling
        integer s1 = 0;
        integer s2 = 0;
        integer s1l= 0;
        integer s2l= -3;
        s1 = llSubStringIndex(body,"<img alt=\"profile image\" src=\"http://secondlife.com/app/image/");
        s1l = llStringLength("<img alt=\"profile image\" src=\"http://secondlife.com/app/image/");
        s2 = llSubStringIndex(body,"\" class=\"parcelimg\" />");
 
        if(s1 == -1)
        {
            // selected AV doesn't have a profile picture, so use the default instead
            ApplyDefaultTexture();
        }
        else
        {
            //check whether this was the texture used last time, no point in refreshing if it is
            if ((key)llGetSubString(body,s1+s1l,s2+s2l) != LastTexture)
            {
                // different profile from last time & not on ExcludeListing, so display it
                ApplySelectedTexture((key)llGetSubString(body,s1+s1l,s2+s2l));
                // save the key for comparison purposes next time tho'
                LastTexture = (key)llGetSubString(body,s1+s1l,s2+s2l);

            }
        }
    }
  
//default end
}
 