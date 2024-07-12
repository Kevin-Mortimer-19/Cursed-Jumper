shader_type canvas_item;

uniform sampler2D scroll_texture: source_color, repeat_enable, filter_nearest;
uniform vec2 scroll_direction = vec2(1.0, 1.0);
uniform float scroll_speed = 1.0;
uniform float zoom_amount = 1.0;

void fragment() {
	vec2 position = vec2(
		UV.x + TIME * scroll_speed * scroll_direction.x,
		UV.y + TIME * scroll_speed * scroll_direction.y
	) * (1.0/zoom_amount);
	COLOR = texture(scroll_texture, position);
}
