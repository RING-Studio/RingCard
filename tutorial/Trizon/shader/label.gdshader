shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 new_texture = texture(TEXTURE, UV);
	//COLOR.rgb = new_texture.rgb;
	//new_texture.a = texture(screen_texture, UV).a * new_texture.a;
	COLOR = new_texture;// * COLOR.a ;
}
