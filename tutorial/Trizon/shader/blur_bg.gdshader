shader_type canvas_item;
uniform float lod: hint_range(0.0, 5) = 0.0;
uniform float alpha: hint_range(0.0, 1.0) = 1.0;
uniform sampler2D screen: hint_screen_texture, filter_linear_mipmap;
uniform float edge: hint_range(0.0, 1.0, 0.01) = 0.05;
uniform float darken = 0.4;
void fragment() {
	vec4 main_texture = texture(screen, SCREEN_UV, lod);
	main_texture.a = main_texture.a * alpha;
	main_texture.rgb = main_texture.rgb * darken;
	COLOR = main_texture;
}
