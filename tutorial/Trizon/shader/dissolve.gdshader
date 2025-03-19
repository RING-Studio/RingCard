shader_type canvas_item;

uniform sampler2D dissolve_texture : source_color, repeat_enable;
uniform float dissolve_value : hint_range(0,1);
uniform sampler2D enchant : source_color, repeat_enable;
uniform float burn_size: hint_range(0.0, 1.0, 0.01);
uniform vec4 burn_color: source_color;
uniform vec4 burn_color2: source_color;
uniform bool shiny = false;
uniform float freeze_progress: hint_range(0.0, 1.0, 0.01);
uniform float randomizer: hint_range(0.0, 3.14, 0.01);
uniform bool enable_burn = false;
uniform bool saturation = false;
uniform float enrich: hint_range(0.0, 1.5, 0.01) = 1.0;
uniform bool rainbow = false;
const float influence = 0.02;
const float TWO_PI = 6.28318530718;

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
vec3 hsv2rgb(vec3 _c) {
    vec4 _K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 _p = abs(fract(_c.xxx + _K.xyz) * 6.0 - _K.www);
    return _c.z * mix(_K.xxx, clamp(_p - _K.xxx, 0.0, 1.0), _c.y);
}
void fragment(){
	if (saturation) {
		vec3 originalColor = COLOR.rgb;
    	float saturationFactor = enrich; // 1.0 is normal, >1 increases saturation
    	COLOR.rgb = increaseSaturation(originalColor, saturationFactor);
	}
	// rainbow
	if (rainbow) {
	    vec2 pos = vec2(0.0) - UV;
	    pos += vec2(1, 1) - UV;
	    // Intensify the spinning by increasing the multiplier
	    float dynamic_offset = (SCREEN_UV.x + SCREEN_UV.y) * 500.0; // Amplified from 50.0 to 500.0
	    COLOR.rgb += influence * hsv2rgb(vec3(((atan(pos.y, pos.x) + radians(dynamic_offset)) / TWO_PI) + 0.5, length(pos) * 5.0, 1.0) * 1.0);
	}
    vec4 noise_texture = texture(dissolve_texture, UV);
	float burn_size_step = burn_size;
	float threshold = smoothstep(max(0.0, noise_texture.x - burn_size_step), noise_texture.x , dissolve_value * (1.0+burn_size_step));
	float border = smoothstep(noise_texture.x, noise_texture.x + burn_size_step, dissolve_value * (1.0+burn_size_step));
	float border2 = smoothstep(min(1.0, noise_texture.x + burn_size_step), noise_texture.x, dissolve_value);
	float burn_size_step2 = burn_size * step(0.01, dissolve_value) * step(dissolve_value, 0.999);
	float threshold2 = smoothstep(noise_texture.x-burn_size_step2, noise_texture.x, dissolve_value);
	if (shiny) {
		vec4 enchant_texture = texture(enchant, 0.65*UV + (vec2(0.3, -0.7) * (TIME+randomizer) * 0.1));
		vec4 layer2 = enchant_texture * vec4(sin(TIME/2.0+randomizer)/1.5+1.0, cos(TIME/1.5+randomizer)/1.2+1.0, 1.0, 0.0);
		COLOR += layer2/4.5;
	}
	if (freeze_progress != 0.0) {
		vec2 to_origin = vec2(smoothstep(0.0, 1.3, abs(UV[0]-0.5)), smoothstep(0.0, 1.3, abs(UV[1]-0.5)));
		float blue = smoothstep(0.0, 1.0, 2.0*max(to_origin[0], to_origin[1]));
		COLOR.rgb += vec3(-blue*0.15, -blue*0.1, blue*0.2) * freeze_progress;
	}
	COLOR.a *= threshold;
	if (enable_burn) {
		COLOR.rgb = mix(burn_color.rgb * threshold2, COLOR.rgb, border) + (burn_color2.rgb) * (border2);
	}
}

void vertex(){
	//VERTEX.x = VERTEX.x + 1.5*sin(TIME);
	VERTEX.y = VERTEX.y - 3.0*cos(TIME+randomizer);
}
