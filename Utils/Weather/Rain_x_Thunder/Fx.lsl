/*
    HEAVY RAIN & THUNDERSTORM FX SYSTEM PRO
    Created by RockzHasan
    Full Permission LSL System

    Place in one child prim used as the flash/optional lightning-bolt surface.
    This script records and restores that prim's original visual properties.
*/

integer LM_FX_EVENT = 91001;
integer LM_FX_STOP  = 91002;
integer LM_MENU     = 91003;
string  BOLT_TEXTURE = "LIGHTNING_BOLT";

list gFaceColors;
list gFaceAlphas;
list gFaceGlows;
list gFaceFullbright;
list gFaceTextures;
list gFaceRepeats;
list gFaceOffsets;
list gFaceRotations;
integer gLightEnabled;
vector gLightColor;
float gLightIntensity;
float gLightRadius;
float gLightFalloff;

integer gActive;
integer gFlashesLeft;
integer gLit;
integer gMajor;
integer gDistance;
integer gNight;

captureNormal()
{
    gFaceColors = []; gFaceAlphas = []; gFaceGlows = []; gFaceFullbright = [];
    gFaceTextures = []; gFaceRepeats = []; gFaceOffsets = []; gFaceRotations = [];
    integer sides = llGetNumberOfSides();
    integer face;
    for (face = 0; face < sides; ++face)
    {
        list data = llGetPrimitiveParams([
            PRIM_COLOR, face, PRIM_GLOW, face, PRIM_FULLBRIGHT, face, PRIM_TEXTURE, face]);
        gFaceColors += [llList2Vector(data, 0)];
        gFaceAlphas += [llList2Float(data, 1)];
        gFaceGlows += [llList2Float(data, 2)];
        gFaceFullbright += [llList2Integer(data, 3)];
        gFaceTextures += [llList2String(data, 4)];
        gFaceRepeats += [llList2Vector(data, 5)];
        gFaceOffsets += [llList2Vector(data, 6)];
        gFaceRotations += [llList2Float(data, 7)];
    }
    list light = llGetPrimitiveParams([PRIM_POINT_LIGHT]);
    gLightEnabled = llList2Integer(light, 0);
    gLightColor = llList2Vector(light, 1);
    gLightIntensity = llList2Float(light, 2);
    gLightRadius = llList2Float(light, 3);
    gLightFalloff = llList2Float(light, 4);
}

restoreFaces()
{
    list rules = [];
    integer sides = llGetListLength(gFaceColors);
    integer face;
    for (face = 0; face < sides; ++face)
    {
        rules += [
            PRIM_COLOR, face, llList2Vector(gFaceColors, face), llList2Float(gFaceAlphas, face),
            PRIM_GLOW, face, llList2Float(gFaceGlows, face),
            PRIM_FULLBRIGHT, face, llList2Integer(gFaceFullbright, face),
            PRIM_TEXTURE, face, llList2String(gFaceTextures, face),
                llList2Vector(gFaceRepeats, face), llList2Vector(gFaceOffsets, face),
                llList2Float(gFaceRotations, face)
        ];
    }
    rules += [PRIM_POINT_LIGHT, gLightEnabled, gLightColor, gLightIntensity, gLightRadius, gLightFalloff];
    llSetLinkPrimitiveParamsFast(LINK_THIS, rules);
}

restoreNormal()
{
    llSetTimerEvent(0.0);
    llParticleSystem([]);
    restoreFaces();
    gActive = FALSE;
    gLit = FALSE;
    gFlashesLeft = 0;
}

flashOn()
{
    float intensity = 0.72;
    float radius = 14.0;
    float glow = 0.15;
    if (gDistance == 2) { intensity = 0.35; radius = 8.0; glow = 0.07; }
    else if (gDistance == 0) { intensity = 1.0; radius = 20.0; glow = 0.25; }
    if (gNight) { intensity *= 1.15; radius += 3.0; }
    if (intensity > 1.0) intensity = 1.0;
    if (gMajor) { intensity = 1.0; radius = 20.0; glow = 0.35; }

    list rules = [
        PRIM_COLOR, ALL_SIDES, <1.0, 1.0, 1.0>, 1.0,
        PRIM_GLOW, ALL_SIDES, glow,
        PRIM_FULLBRIGHT, ALL_SIDES, TRUE,
        PRIM_POINT_LIGHT, TRUE, <0.86, 0.92, 1.0>, intensity, radius, 0.55
    ];
    if (gMajor && llGetInventoryType(BOLT_TEXTURE) == INVENTORY_TEXTURE)
        rules += [PRIM_TEXTURE, ALL_SIDES, BOLT_TEXTURE, <1.0, 1.0, 0.0>, ZERO_VECTOR, 0.0];
    llSetLinkPrimitiveParamsFast(LINK_THIS, rules);
    if (gMajor)
    {
        llParticleSystem([
            PSYS_PART_FLAGS, PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK,
            PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
            PSYS_SRC_BURST_PART_COUNT, 10,
            PSYS_SRC_BURST_RATE, 0.1,
            PSYS_SRC_BURST_SPEED_MIN, 0.5,
            PSYS_SRC_BURST_SPEED_MAX, 2.0,
            PSYS_PART_START_COLOR, <1.0, 1.0, 1.0>,
            PSYS_PART_END_COLOR, <0.4, 0.6, 1.0>,
            PSYS_PART_START_ALPHA, 0.9,
            PSYS_PART_END_ALPHA, 0.0,
            PSYS_PART_START_SCALE, <0.08, 0.35, 0.0>,
            PSYS_PART_END_SCALE, <0.02, 0.05, 0.0>,
            PSYS_PART_MAX_AGE, 0.45,
            PSYS_SRC_MAX_AGE, 0.12
        ]);
    }
    gLit = TRUE;
    llSetTimerEvent(0.055 + llFrand(0.07));
}

flashOff()
{
    llParticleSystem([]);
    restoreFaces();
    gLit = FALSE;
    --gFlashesLeft;
    if (gFlashesLeft <= 0)
    {
        gActive = FALSE;
        llSetTimerEvent(0.0);
    }
    else llSetTimerEvent(0.06 + llFrand(0.14));
}

startEvent(integer style, integer distanceClass, integer major, integer night)
{
    restoreNormal();
    gDistance = distanceClass;
    gMajor = major;
    gNight = night;
    gFlashesLeft = style;
    if (gMajor) gFlashesLeft = 4;
    gActive = TRUE;
    flashOn();
}

default
{
    state_entry()
    {
        captureNormal();
        restoreNormal();
    }

    on_rez(integer startParameter) { llResetScript(); }

    changed(integer change)
    {
        if (change & CHANGED_OWNER) llResetScript();
        if (change & CHANGED_LINK) llResetScript();
        if ((change & CHANGED_INVENTORY) && !gActive) captureNormal();
    }

    link_message(integer senderNumber, integer number, string message, key id)
    {
        if (number == LM_FX_STOP) restoreNormal();
        else if (number == LM_FX_EVENT)
        {
            list fields = llParseString2List(message, ["|"], []);
            if (llGetListLength(fields) == 4)
                startEvent(llList2Integer(fields, 0), llList2Integer(fields, 1),
                           llList2Integer(fields, 2), llList2Integer(fields, 3));
        }
    }

    touch_start(integer totalNumber)
    {
        // Allow the visible child prim to open the controller menu even when
        // the rain-emitter root is high overhead and difficult to touch.
        llMessageLinked(LINK_ROOT, LM_MENU, "MENU", llDetectedKey(0));
    }

    timer()
    {
        if (!gActive) { restoreNormal(); return; }
        if (gLit) flashOff(); else flashOn();
    }
}
