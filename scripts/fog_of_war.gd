# FogOfWar.gd
# Attach to a CanvasLayer node (layer = 10 or above your game layer)
# Sibling of BaseSpawner and WorldMap under the same scene root.

extends CanvasLayer

# ─────────────────────────────────────────
#  Configuration
# ─────────────────────────────────────────

@export var fog_color     : Color = Color(0.874, 0.671, 0.78, 1.0)
@export var edge_softness : float = 0.5  # in chunks

# ─────────────────────────────────────────
#  Internals
# ─────────────────────────────────────────

var _rect      : ColorRect
var _mat       : ShaderMaterial
var _world_map : Node = null

const _SHADER_CODE := """
shader_type canvas_item;

uniform vec2  player_screen_pos = vec2(0.5, 0.5);
uniform float reveal_radius     = 0.25;
uniform float edge_softness     = 0.02;
uniform vec4  fog_color : source_color = vec4(0.0, 0.0, 0.0, 0.85);

void fragment() {
    float dist  = distance(UV, player_screen_pos);
    float alpha = smoothstep(reveal_radius - edge_softness,
                             reveal_radius + edge_softness,
                             dist);
    COLOR = vec4(fog_color.rgb, fog_color.a * alpha);
}
"""

# ─────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────

func _ready() -> void:
	layer = 10

	_world_map = get_tree().root.find_child("WorldMap", true, false)
	if not _world_map:
		push_error("FogOfWar: could not find 'WorldMap'.")

	_rect = ColorRect.new()
	_rect.anchor_right  = 1.0
	_rect.anchor_bottom = 1.0
	_rect.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)

	var shader : Shader = Shader.new()
	shader.code = _SHADER_CODE

	_mat = ShaderMaterial.new()
	_mat.shader = shader
	_rect.material = _mat

	_push_uniforms()

func _process(_delta: float) -> void:
	_push_uniforms()

# ─────────────────────────────────────────
#  Uniform Update
# ─────────────────────────────────────────

func _push_uniforms() -> void:
	var player : Node2D = _get_player()
	if not player or not _world_map:
		return

	var viewport : Viewport = get_viewport()
	var vp_size  : Vector2  = Vector2(viewport.get_visible_rect().size)

	# World → screen position
	var screen_pos : Vector2 = viewport.get_canvas_transform() * player.global_position
	var norm_pos   : Vector2 = screen_pos / vp_size

	# Radius: field_of_view chunks × 64 px/chunk, then normalised to screen height
	var chunk_size   : int   = _world_map.get_chunk_size()
	var view_dist    : int   = _world_map.get_view_distance()
	var fov_pixels   : float = float(view_dist) * float(chunk_size)
	var soft_pixels  : float = edge_softness * float(chunk_size)

	var norm_radius   : float = fov_pixels  / vp_size.y
	var norm_softness : float = soft_pixels / vp_size.y

	_mat.set_shader_parameter("player_screen_pos", norm_pos)
	_mat.set_shader_parameter("reveal_radius",     norm_radius)
	_mat.set_shader_parameter("edge_softness",     norm_softness)
	_mat.set_shader_parameter("fog_color",         fog_color)

# ─────────────────────────────────────────
#  Helpers
# ─────────────────────────────────────────

func _get_player() -> Node2D:
	if PlayerManager and PlayerManager.player:
		return PlayerManager.player
	return null
