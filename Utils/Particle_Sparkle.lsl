default
{
    state_entry()
    {
        // Emit a sparkling particle effect
        llParticleSystem([
            PSYS_SRC_TEXTURE, "", // Uses default texture
            PSYS_PART_FLAGS, (integer)(PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK),
            PSYS_PART_START_COLOR, <1.0, 1.0, 1.0>,
            PSYS_PART_END_COLOR, <1.0, 1.0, 1.0>,
            PSYS_PART_START_ALPHA, 1.0,
            PSYS_PART_END_ALPHA, 0.0,
            PSYS_PART_START_SCALE, <0.1, 0.1, 0.0>,
            PSYS_PART_END_SCALE, <0.5, 0.5, 0.0>,
            PSYS_PART_MAX_AGE, 0.5,
            PSYS_SRC_BURST_RATE, 0.2,
            PSYS_SRC_BURST_PART_COUNT, 3,
            PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_EXPLODE,
            PSYS_SRC_BURST_RADIUS, 0.3,
            PSYS_SRC_BURST_SPEED_MIN, 0.0,
            PSYS_SRC_BURST_SPEED_MAX, 0.5
        ]);
    }
}
