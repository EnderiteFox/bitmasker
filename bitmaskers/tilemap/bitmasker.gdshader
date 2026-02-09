shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;
uniform float stripe_width = 64;
uniform int border_width = 8;
uniform float border_alpha_mult = 4.0;
uniform float anim_speed = 30.0;
varying vec2 world_position;

void vertex() {
	// calculate the world position for use in the fragment shader
	world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);

	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}

	COLOR *= c;
	
	vec2 world_pos = world_position + 1.0 / TEXTURE_PIXEL_SIZE;
	
	if (
		texture(screen_texture, vec2(SCREEN_UV.x + float(border_width) * SCREEN_PIXEL_SIZE.x, SCREEN_UV.y + float(border_width) * SCREEN_PIXEL_SIZE.y)).a < 0.01
		|| texture(screen_texture, vec2(SCREEN_UV.x - float(border_width) * SCREEN_PIXEL_SIZE.x, SCREEN_UV.y - float(border_width) * SCREEN_PIXEL_SIZE.y)).a < 0.01
		|| texture(screen_texture, vec2(SCREEN_UV.x - float(border_width) * SCREEN_PIXEL_SIZE.x, SCREEN_UV.y + float(border_width) * SCREEN_PIXEL_SIZE.y)).a < 0.01
		|| texture(screen_texture, vec2(SCREEN_UV.x + float(border_width) * SCREEN_PIXEL_SIZE.x, SCREEN_UV.y - float(border_width) * SCREEN_PIXEL_SIZE.y)).a < 0.01
	) {
		COLOR.a *= border_alpha_mult;
	}
	
	float stripe_val = mod(world_pos.x + world_pos.y - TIME * anim_speed, stripe_width);
	if (stripe_val < stripe_width / 2.0) {
		COLOR.a /= 2.0;
	}
}
