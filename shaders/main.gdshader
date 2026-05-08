shader_type sky;

uniform vec3 sky_top_color : source_color = vec3(0.02, 0.0, 0.05); // Deep purple/black
uniform vec3 sky_horizon_color : source_color = vec3(0.1, 0.1, 0.3); // Blueish glow
uniform float horizon_blur : hint_range(0.0, 1.0) = 0.2;

uniform vec3 moon_color : source_color = vec3(0.9, 0.9, 0.8);
uniform float moon_size : hint_range(0.01, 0.5) = 0.05;
uniform float moon_crescent_offset : hint_range(-0.1, 0.1) = -0.02; // Controls crescent shape

uniform float star_density : hint_range(10.0, 100.0) = 50.0;
uniform float star_brightness : hint_range(1.0, 10.0) = 5.0;

// Simple pseudo-random function
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Generates a star field
float stars(vec3 direction) {
    // Project 3D direction to 2D for tiling
    vec2 uv = direction.xz / (direction.y + 1.5); // Simple dome projection

    // Grid based noise
    vec2 grid_uv = uv * star_density;
    vec2 grid_id = floor(grid_uv);
    vec2 grid_local = fract(grid_uv);

    float rnd = random(grid_id);

    // Only draw star if random value is high enough (sparse stars)
    if (rnd > 0.95) {
        // Center the star within the grid cell
        float star = distance(grid_local, vec2(0.5));
        // Make it small and sharp
        star = 1.0 - smoothstep(0.0, 0.1 * rnd, star);
        return star * rnd;
    }
    return 0.0;
}

void sky() {
    // 1. Background Gradient
    float y = EYEDIR.y;
    float gradient_mask = smoothstep(-horizon_blur, 0.5, y);
    vec3 final_color = mix(sky_horizon_color, sky_top_color, gradient_mask);

    // 2. Stars
    // Only show stars in the upper part of the sky to avoid them bleeding into the ground
    float star_mask = smoothstep(0.0, 0.2, y);
    float star_intensity = stars(EYEDIR);
    final_color += vec3(star_intensity) * star_brightness * star_mask;

    // 3. Moon (based on LIGHT0_DIRECTION)
    // We draw two circles: The main moon, and a "shadow" circle slightly offset to create a crescent
    float moon_dist = distance(EYEDIR, LIGHT0_DIRECTION);
    float moon_mask = 1.0 - step(moon_size, moon_dist);

    // Create the crescent shadow (offset slightly to the right/left)
    vec3 shadow_dir = normalize(LIGHT0_DIRECTION + vec3(moon_crescent_offset, 0.0, 0.0));
    float shadow_dist = distance(EYEDIR, shadow_dir);
    float shadow_mask = 1.0 - step(moon_size, shadow_dist);

    // Subtract shadow from moon (ensure we don't go below 0)
    float crescent = clamp(moon_mask - shadow_mask, 0.0, 1.0);

    final_color += crescent * moon_color;

    COLOR = final_color;
}