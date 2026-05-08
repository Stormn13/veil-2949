shader_type spatial;
render_mode unshaded; // Makes it glow (ignores lighting), remove if you want shadows

// Settings you can tweak in the Inspector
uniform float static_intensity : hint_range(0.0, 1.0) = 1.0;
uniform float speed : hint_range(0.0, 20.0) = 10.0;
uniform vec3 static_color : source_color = vec3(1.0, 1.0, 1.0); // White static

// Random noise function
float random (vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    // 1. Create a coordinate that moves over time
    vec2 time_offset = vec2(0.0, TIME * speed);

    // 2. Generate noise based on UV + Time
    // We add 'TIME' to the random seed so the noise pattern changes every frame
    float noise = random(UV + time_offset);

    // 3. Apply the color
    vec3 final_color = static_color * noise * static_intensity;

    ALBEDO = final_color;
}