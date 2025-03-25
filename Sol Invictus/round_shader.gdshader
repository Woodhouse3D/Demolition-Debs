shader_type canvas_item;

uniform sampler2D mask;

vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat)
{
	vec2 dir = uv - center;
	float radius = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) * 1.0/(3.1416 * 2.0);
	return mod(vec2(radius * zoom, angle * repeat), 1.0);
}

void fragment(){
	vec2 polar_uv = polar_coordinates(UV.xy, vec2(0.5), 1, 1);
	vec4 mask_color = texture(mask, UV).rgba;
	vec4 sprite_color = texture(TEXTURE, polar_uv).rgba;
	
	if (mask_color.a == 0.0)
		{ sprite_color.a = 0.0; }
	COLOR = sprite_color;
}

