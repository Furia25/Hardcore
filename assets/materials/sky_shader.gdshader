shader_type sky;

uniform vec4 color : source_color;

void sky() {
	COLOR = vec3(EYEDIR.y * 3.);
}
