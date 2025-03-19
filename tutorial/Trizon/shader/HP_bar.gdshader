shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0, 0.01);

void fragment() {
	if (progress != 1.0 && UV[0] + 0.1 * (-1.0+UV[1]/2.0) < 0.9-progress) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}
