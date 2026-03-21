
extends Node2D

# ─────────────────────────────────────────
#  Configuration
# ─────────────────────────────────────────

const DETAIL_DENSITY   := 0.93   # 0–1, higher = sparser
const DETAIL_SCALE     := 0.4   # base sprite scale
const DETAIL_SCALE_MIN := 0.5   # random size range min (multiplier)
const DETAIL_SCALE_MAX := 1.5   # random size range max (multiplier)
const DETAIL_STEP      := 2      # pixel step when scanning chunk (higher = fewer details)
const NOISE_FREQUENCY  := 0.22   # placement noise frequency
const NOISE_OCTAVES    := 2      # placement noise octaves
const NOISE_SEED       := 0      # 0 = random on start

const DETAILS : Dictionary = {
	"grass": [
		preload("res://assets/sprites/deco/heb2.svg"),
		preload("res://assets/sprites/deco/herb1.svg"),
		preload("res://assets/sprites/deco/herb3.svg"),
	],
	"sand": [],
	"ocean": [],
}

# ─────────────────────────────────────────
#  State
# ─────────────────────────────────────────

var _map              : Node2D
var _active_roots     : Dictionary      = {}
var _generation_queue : Array[Vector2]  = []
var _last_chunk       := Vector2(INF, INF)
var _ready_done       := false
var _noise            := FastNoiseLite.new()

# ─────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────

func _ready() -> void:
	_map = get_parent().get_node("WorldMap")
	if not _map:
		push_error("WorldDetails: could not find WorldMap node")
		return
	_setup_noise()
	_ready_done = true

func _process(_delta: float) -> void:
	if not _ready_done or not _map:
		return

	var player := _get_player()
	if not player:
		return

	var chunk_size   : int     = _map.get_chunk_size()
	var player_chunk : Vector2 = _world_to_chunk(player.global_position, chunk_size)

	if player_chunk != _last_chunk:
		_last_chunk = player_chunk
		_queue_visible_chunks(player_chunk)
		_unload_distant_chunks(player_chunk)

	for i in range(4):
		if _generation_queue.is_empty():
			break
		_populate_chunk(_generation_queue.pop_front())

# ─────────────────────────────────────────
#  Noise Setup
# ─────────────────────────────────────────

func _setup_noise() -> void:
	_noise.noise_type      = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.seed            = NOISE_SEED if NOISE_SEED != 0 else randi()
	_noise.frequency       = NOISE_FREQUENCY
	_noise.fractal_octaves = NOISE_OCTAVES

# ─────────────────────────────────────────
#  Chunk Queuing
# ─────────────────────────────────────────

func _queue_visible_chunks(player_chunk: Vector2) -> void:
	_generation_queue.clear()

	var view     : int            = _map.get_view_distance()
	var to_queue : Array[Vector2] = []

	for x in range(-view, view + 1):
		for y in range(-view, view + 1):
			var coord := player_chunk + Vector2(x, y)
			if not _active_roots.has(coord):
				to_queue.append(coord)

	to_queue.sort_custom(func(a, b):
		return a.distance_squared_to(player_chunk) < b.distance_squared_to(player_chunk)
	)
	_generation_queue = to_queue

func _unload_distant_chunks(player_chunk: Vector2) -> void:
	var threshold : float = _map.get_view_distance() + _map.get_unload_margin()

	_generation_queue = _generation_queue.filter(func(coord):
		return coord.distance_to(player_chunk) <= threshold
	)

	var to_remove : Array[Vector2] = []
	for coord in _active_roots.keys():
		if (coord as Vector2).distance_to(player_chunk) > threshold:
			to_remove.append(coord)

	for coord in to_remove:
		_active_roots[coord].queue_free()
		_active_roots.erase(coord)

# ─────────────────────────────────────────
#  Detail Population
# ─────────────────────────────────────────

func _populate_chunk(chunk_coord: Vector2) -> void:
	if _active_roots.has(chunk_coord):
		return

	var chunk_size : int = _map.get_chunk_size()
	var root       := Node2D.new()
	add_child(root)
	_active_roots[chunk_coord] = root

	for px in range(0, chunk_size, DETAIL_STEP):
		for py in range(0, chunk_size, DETAIL_STEP):
			var world_x : float = chunk_coord.x * chunk_size + px
			var world_y : float = chunk_coord.y * chunk_size + py

			var value : float = _noise.get_noise_2d(world_x, world_y) * 0.5 + 0.5
			if value < DETAIL_DENSITY:
				continue

			var biome : String = _map.get_biome_at(Vector2(world_x, world_y))
			if not DETAILS.has(biome):
				continue
			var options : Array = DETAILS[biome]
			if options.is_empty():
				continue

			# Deterministic variety + scale from noise value, no extra RNG calls
			var idx             : int   = int(value * 1000.0) % options.size()
			var scale_t         : float = fmod(value * 397.0, 1.0)
			var scale_v         : float = lerp(DETAIL_SCALE_MIN, DETAIL_SCALE_MAX, scale_t) * DETAIL_SCALE

			var spr             := Sprite2D.new()
			spr.texture          = options[idx]
			spr.centered         = true
			spr.z_index          = 1
			spr.global_position  = Vector2(world_x, world_y)
			spr.scale            = Vector2(scale_v, scale_v)

			root.add_child(spr)

# ─────────────────────────────────────────
#  Helpers
# ─────────────────────────────────────────

func _world_to_chunk(world_pos: Vector2, chunk_size: int) -> Vector2:
	return Vector2(floor(world_pos.x / chunk_size), floor(world_pos.y / chunk_size))

func _get_player() -> Node2D:
	if PlayerManager and PlayerManager.player:
		return PlayerManager.player
	return null
