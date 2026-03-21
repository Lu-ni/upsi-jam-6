shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	vec4 current = texture(TEXTURE, UV);
	
	vec2 size = outline_width / vec2(textureSize(TEXTURE, 0));
	
	float alpha = current.a;
	alpha = max(alpha, texture(TEXTURE, UV + vec2(size.x, 0.0)).a);
	alpha = max(alpha, texture(TEXTURE, UV - vec2(size.x, 0.0)).a);
	alpha = max(alpha, texture(TEXTURE, UV + vec2(0.0, size.y)).a);
	alpha = max(alpha, texture(TEXTURE, UV - vec2(0.0, size.y)).a);
	
	vec4 outline = vec4(outline_color.rgb, outline_color.a * alpha);
	COLOR = mix(outline, current, current.a);
}