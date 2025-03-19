shader_type canvas_item;

uniform float height = 20.0;
uniform float frequency = 0.5;
uniform float speed = 3.0;
uniform float offset = 0.0;
uniform float offset2 = 0.0;
void vertex() {
	VERTEX.y += height * sin((frequency * UV.x) + (speed * TIME)) + offset;
	VERTEX.x += offset2;
}