shader_type canvas_item;
uniform float randomizer: hint_range(0.0, 3.14, 0.01);
uniform float edge: hint_range(0.0, 1.0, 0.01) = 0.05;
void vertex(){
	VERTEX.y = VERTEX.y - 3.0*cos(TIME+randomizer);
}

void fragment() {
	float luminance = 0.299 * COLOR.r + 0.587 * COLOR.g + 0.114 * COLOR.b;
	COLOR.rgb = vec3(luminance);
	float dis_to_mid = max(abs(UV[1] - 0.5), 0.5 - UV[0]);
	float dis = smoothstep(1.0, -1.0, (dis_to_mid-0.5+edge)/edge);
	COLOR.a = dis * COLOR.a;


}
