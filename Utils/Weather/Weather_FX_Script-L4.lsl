integer gMenuChannel;
integer gListenHandle;

integer gMode = 0;
// 0 Off
// 1 Rain
// 2 Snow
// 3 Mist

integer gIntensity = 2;

string gRainTexture = "Rain";
string gSnowTexture = "Snow";
string gMistTexture = "Mist";

applyWeather()
{
    float burstRate;
    integer burstCount;

    if (gIntensity == 1)
    {
        burstRate = 0.12;
        burstCount = 3;
    }
    else if (gIntensity == 2)
    {
        burstRate = 0.07;
        burstCount = 6;
    }
    else
    {
        burstRate = 0.04;
        burstCount = 10;
    }

    if (gMode == 0)
    {
        llParticleSystem([]);
        return;
    }

    if (gMode == 1)
    {
        llParticleSystem([
            PSYS_PART_FLAGS,
            PSYS_PART_INTERP_COLOR_MASK |
            PSYS_PART_INTERP_SCALE_MASK,

            PSYS_SRC_PATTERN,
            PSYS_SRC_PATTERN_EXPLODE,

            PSYS_PART_START_COLOR,
            <0.70, 0.82, 1.00>,

            PSYS_PART_END_COLOR,
            <0.55, 0.70, 1.00>,

            PSYS_PART_START_ALPHA,
            0.75,

            PSYS_PART_END_ALPHA,
            0.05,

            PSYS_PART_START_SCALE,
            <0.025, 0.40, 0.0>,

            PSYS_PART_END_SCALE,
            <0.015, 0.28, 0.0>,

            PSYS_PART_MAX_AGE,
            2.3,

            PSYS_SRC_BURST_RATE,
            burstRate,

            PSYS_SRC_BURST_PART_COUNT,
            burstCount,

            PSYS_SRC_BURST_RADIUS,
            7.0,

            PSYS_SRC_BURST_SPEED_MIN,
            0.0,

            PSYS_SRC_BURST_SPEED_MAX,
            1.0,

            PSYS_SRC_ACCEL,
            <0.0, 0.0, -8.0>,

            PSYS_SRC_TEXTURE,
            gRainTexture
        ]);

        return;
    }

    if (gMode == 2)
    {
        llParticleSystem([
            PSYS_PART_FLAGS,
            PSYS_PART_INTERP_COLOR_MASK |
            PSYS_PART_INTERP_SCALE_MASK,

            PSYS_SRC_PATTERN,
            PSYS_SRC_PATTERN_EXPLODE,

            PSYS_PART_START_COLOR,
            <1.0, 1.0, 1.0>,

            PSYS_PART_END_COLOR,
            <0.85, 0.92, 1.0>,

            PSYS_PART_START_ALPHA,
            0.95,

            PSYS_PART_END_ALPHA,
            0.15,

            PSYS_PART_START_SCALE,
            <0.10, 0.10, 0.0>,

            PSYS_PART_END_SCALE,
            <0.22, 0.22, 0.0>,

            PSYS_PART_MAX_AGE,
            7.0,

            PSYS_SRC_BURST_RATE,
            burstRate * 1.5,

            PSYS_SRC_BURST_PART_COUNT,
            burstCount,

            PSYS_SRC_BURST_RADIUS,
            7.0,

            PSYS_SRC_BURST_SPEED_MIN,
            0.2,

            PSYS_SRC_BURST_SPEED_MAX,
            1.2,

            PSYS_SRC_ACCEL,
            <0.15, 0.05, -0.65>,

            PSYS_SRC_TEXTURE,
            gSnowTexture
        ]);

        return;
    }

    llParticleSystem([
        PSYS_PART_FLAGS,
        PSYS_PART_INTERP_COLOR_MASK |
        PSYS_PART_INTERP_SCALE_MASK,

        PSYS_SRC_PATTERN,
        PSYS_SRC_PATTERN_EXPLODE,

        PSYS_PART_START_COLOR,
        <0.80, 0.84, 0.88>,

        PSYS_PART_END_COLOR,
        <0.90, 0.92, 0.95>,

        PSYS_PART_START_ALPHA,
        0.18,

        PSYS_PART_END_ALPHA,
        0.0,

        PSYS_PART_START_SCALE,
        <1.5, 1.5, 0.0>,

        PSYS_PART_END_SCALE,
        <3.5, 3.5, 0.0>,

        PSYS_PART_MAX_AGE,
        8.0,

        PSYS_SRC_BURST_RATE,
        burstRate * 2.0,

        PSYS_SRC_BURST_PART_COUNT,
        burstCount / 2 + 1,

        PSYS_SRC_BURST_RADIUS,
        5.0,

        PSYS_SRC_BURST_SPEED_MIN,
        0.05,

        PSYS_SRC_BURST_SPEED_MAX,
        0.35,

        PSYS_SRC_ACCEL,
        <0.08, 0.02, 0.03>,

        PSYS_SRC_TEXTURE,
        gMistTexture
    ]);
}

string modeName()
{
    if (gMode == 1)
    {
        return "Rain";
    }

    if (gMode == 2)
    {
        return "Snow";
    }

    if (gMode == 3)
    {
        return "Mist";
    }

    return "Off";
}

default
{
    state_entry()
    {
        gMenuChannel =
            -300000 -
            (integer)llFrand(
                9000000.0
            );

        llSetTouchText("Weather");

        applyWeather();
    }
}