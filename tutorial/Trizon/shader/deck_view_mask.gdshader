shader_type canvas_item;
uniform sampler2D screen: hint_screen_texture;
uniform float edge: hint_range(0.0, 1.0, 0.01) = 0.05;
void fragment() {
	vec4 main_texture = texture(screen, SCREEN_UV);
	float dis_to_mid = abs(UV[1] - 0.5);
	if (0.5 - dis_to_mid <= edge) {
		float dis = smoothstep(-edge*1.8, 1.0, (abs(UV[1] - 0.5)-0.5+edge)/edge);
		main_texture.a = dis;
		COLOR = main_texture;
	}
}