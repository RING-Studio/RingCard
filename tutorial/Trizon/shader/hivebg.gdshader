shader_type canvas_item;
uniform float shift;
vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

float worley(vec2 uv, float columns, float rows, float time) {

	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));

	float minimum_dist = 1.0;

	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);
			float speed = 4.5;
			point = vec2( cos(time * point.x * speed), sin(time * point.y * speed) ) * 0.4 + 0.2;
			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}

	return clamp(minimum_dist, 0.0, 1.0);
}
vec2 voronoi(vec2 uv, float columns, float rows, float time) {

	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));

	float minimum_dist = 1.0;
	vec2 minimum_point;

	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);
			//float speed = 4.5;
			//point = vec2( cos(time * point.x * speed), sin(time * point.y * speed) ) * 0.5 + 0.5;
			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);

			if(dist < minimum_dist) {
				minimum_dist = dist;
				minimum_point = point;
			}
		}
	}
	return minimum_point;
}
/*
void fragment() {
	float color = voronoi(UV, 10.0 + sin(TIME/5.0)/2.0, 8.0 + cos(TIME/5.0)/2.0, TIME/100.0).r;
	float r = smoothstep(0.8, 0.0, color);
	float g = smoothstep(0.45, 0.0, color);
	float b = smoothstep(0.9, 0.0, color);
	COLOR.rgb = vec3(r, g, b);
}
*/
void fragment() {
	float time = TIME + shift;
	float worley = worley(UV, 5.0 + sin(time/10.0)/20.0, 4.0 + cos(time/10.0)/20.0, time/40.0);
	COLOR = vec4(worley/2.0);
	COLOR.rgb += vec3(0.1, -0.1, 0.1);
	vec2 to_origin = vec2(smoothstep(0.0, 1.0, abs(UV[0]-0.5)), smoothstep(0.0, 1.0, abs(UV[1]-0.5)));
	COLOR.a = COLOR.a * smoothstep(1.0, 0.0, 2.0*max(to_origin[0], to_origin[1]));
}
