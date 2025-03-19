shader_type canvas_item;
uniform float randomizer: hint_range(0.0, 3.14, 0.01);
uniform float freeze_progress: hint_range(0.0, 1.0, 0.01);
void vertex() {
	VERTEX.y = VERTEX.y - 3.0*cos(TIME+randomizer);
}

void fragment() {
	vec4 main_texture = texture(TEXTURE, UV);
	if (freeze_progress != 0.0) {
		vec2 to_origin = vec2(smoothstep(0.0, 1.5-1.5*freeze_progress, abs(UV[0]-0.5)), smoothstep(0.0, 1.5-1.5*freeze_progress, abs(UV[1]-0.5)));
		float blue = smoothstep(0.0, 1.0, 1.0*max(to_origin[0], to_origin[1]));
		main_texture.a = main_texture.a * blue;
		COLOR = main_texture;
	} else {
		COLOR.a = 0.0;
	}
}
