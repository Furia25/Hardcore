shader_type sky;

group_uniforms Sky;
uniform bool use_directional_light = false;
uniform vec4 sun_color : source_color = vec4(1.0);
uniform float sun_energy = 15.0;
uniform vec4 dark_sun_color : source_color = vec4(0.05, 0.01, 0.02, 1.0); // teinte du "dark sun"
uniform float dark_sun_strength = 1.4; // intensité de l'effet sombre
uniform float night : hint_range(0.0, 1.0) = 0.0; // slider principal pour basculer jour/nuit

uniform vec4 cloud_color : source_color = vec4(0.296, 0.402, 0.521, 1.0);
uniform float cloud_density = 5.0;
uniform float cloud_depth = 2.0;
uniform float cloud_sag = 2.0;
uniform sampler2D noise_texture;
uniform vec2 noise_tiling = vec2(1.0);
uniform vec2 wind_speed = vec2(0.5);
group_uniforms;

group_uniforms Ground;
uniform vec4 ground_bottom_color : source_color = vec4(0.2, 0.169, 0.133, 1.0);
uniform float ground_curve : hint_range(0, 1) = 0.04;
group_uniforms;

uniform float exposure : hint_range(0, 128) = 1.0;

float ray_plane_intersection(vec3 origin, vec3 normal, vec3 ray_start, vec3 ray_dir) {
	return dot(origin - ray_start, normal) / dot(ray_dir, normal);
}

float beers_law(float absorption, float dist) {
	return exp(-absorption * dist);
}

float sample_fbm(vec2 uv) {
	float v = 0.0;
	float amp = 0.5;
	float freq = 1.0;
	for (int i = 0; i < 3; i++) {
		v += amp * texture(noise_texture, uv * freq).r;
		amp *= 0.5;
		freq *= 2.0;
		uv += vec2(37.0, 17.0);
	}
	return v;
}

float sample_height(vec2 uv) {
	float h = sample_fbm(uv * noise_tiling);
	return pow(h, cloud_sag);
}

void sky() {
	vec3 light_color = LIGHT0_COLOR.rgb * LIGHT0_ENERGY * max(0.0, dot(LIGHT0_DIRECTION, vec3(0.0, 1.0, 0.0)));

	vec3 sky_col = cloud_color.rgb;

	float t = ray_plane_intersection(vec3(0.0, 1.0, 0.0), vec3(0.0, -1.0, 0.0), vec3(0.0), EYEDIR);
	if (t >= 0.0) {
		vec3 wind = vec3(wind_speed.x, 0.0, wind_speed.y) * TIME * 0.1;
		vec3 tiling = vec3(noise_tiling.x, 1.0, noise_tiling.y) * 0.2;
		vec3 cloud_pos = EYEDIR * t * tiling + wind;

		float height = sample_height(cloud_pos.xz);
		cloud_pos += EYEDIR * height * cloud_depth * 0.1;
		height = sample_height(cloud_pos.xz);

		float n_dot_v = max(0.0, dot(vec3(0.0, 1.0, 0.0), EYEDIR));
		float cloud_light = beers_law(cloud_density, 1.0 - height * n_dot_v);

		sky_col += light_color * cloud_light;
	}

	vec3 horizon = cloud_color.rgb + light_color * beers_law(cloud_density, 1.0);
	vec3 ground = mix(horizon, ground_bottom_color.rgb, clamp(1.0 - pow(1.0 + EYEDIR.y, 1.0 / max(0.0001, ground_curve)), 0.0, 1.0));

	vec3 sun_dir = vec3(0.0, 1.0, 0.0);
	sun_dir = normalize(LIGHT0_DIRECTION);
	float cos_a = dot(normalize(EYEDIR), normalize(sun_dir));
	cos_a = clamp(cos_a, -1.0, 1.0);
	float angle = acos(cos_a);

	float sun_radius = radians(3.5);
	float sun_softness = radians(3.5);
	float sun_mask = 1.0 - smoothstep(sun_radius, sun_radius + sun_softness, angle);

	vec3 sun_day = light_color * sun_mask;

	vec3 dark_tint = dark_sun_color.rgb * dark_sun_strength * 100.;
	vec3 sun_night_effect = -dark_tint * sun_mask;
	vec3 sun_final = mix(sun_day, sun_night_effect, night);

	sky_col += sun_final;

	vec3 sky_final = max(vec3(0.0), sky_col);

	vec3 out_col = mix(ground, sky_final, step(0.0, EYEDIR.y));
	out_col *= mix(1.0, 0.25, night);
	COLOR = clamp(out_col * exposure, 0.0, 1.0);
}
