shader_type canvas_item;
uniform sampler2D screen: hint_screen_texture, filter_linear_mipmap;
uniform bool saturation = true;
uniform float enrich: hint_range(0.0, 1.5, 0.01) = 1.2;

vec3 rgbToHsv(vec3 c) {
    float maxC = max(max(c.r, c.g), c.b);
    float minC = min(min(c.r, c.g), c.b);
    float delta = maxC - minC;

    float h = 0.0;
    if (delta > 0.0) {
        if (maxC == c.r) {
            h = mod((c.g - c.b) / delta, 6.0);
        } else if (maxC == c.g) {
            h = (c.b - c.r) / delta + 2.0;
        } else {
            h = (c.r - c.g) / delta + 4.0;
        }
        h /= 6.0;
        if (h < 0.0) h += 1.0;
    }

    float s = (maxC > 0.0) ? delta / maxC : 0.0;
    float v = maxC;

    return vec3(h, s, v);
}
vec3 adjustSaturation(vec3 hsv, float saturationFactor) {
    hsv.g *= saturationFactor; // hsv.g is the saturation component
    hsv.g = clamp(hsv.g, 0.0, 1.0); // Ensure it stays within valid range
    return hsv;
}
vec3 hsvToRgb(vec3 c) {
    float h = c.x * 6.0;
    float s = c.y;
    float v = c.z;

    float k = floor(h);
    float f = h - k;
    float p = v * (1.0 - s);
    float q = v * (1.0 - f * s);
    float t = v * (1.0 - (1.0 - f) * s);

    if (mod(k, 6.0) == 0.0) return vec3(v, t, p);
    if (mod(k, 6.0) == 1.0) return vec3(q, v, p);
    if (mod(k, 6.0) == 2.0) return vec3(p, v, t);
    if (mod(k, 6.0) == 3.0) return vec3(p, q, v);
    if (mod(k, 6.0) == 4.0) return vec3(t, p, v);
    return vec3(v, p, q);
}
vec3 increaseSaturation(vec3 color, float saturationFactor) {
    vec3 hsv = rgbToHsv(color);
    hsv = adjustSaturation(hsv, saturationFactor);
    return hsvToRgb(hsv);
}

void fragment(){
	vec4 main_texture = texture(screen, SCREEN_UV);
	if (saturation) {
		vec3 originalColor = main_texture.rgb;
    	float saturationFactor = enrich;
    	main_texture.rgb = increaseSaturation(originalColor, saturationFactor);
	}
	COLOR = main_texture;
	//COLOR.a = main_texture.a * 0.3;
}