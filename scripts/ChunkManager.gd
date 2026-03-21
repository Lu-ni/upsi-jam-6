extends Node2D

# ─────────────────────────────────────────
#  Configuration
# ─────────────────────────────────────────

const CHUNK_SIZE       := 64
const VIEW_DISTANCE    := 14
const UNLOAD_MARGIN    := 1.5
const CHUNKS_PER_FRAME := 4

const FILTER_MODE := CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

# ─────────────────────────────────────────
#  State
# ─────────────────────────────────────────

var _active_chunks     : Dictionary = {}
var _last_player_chunk := Vector2(INF, INF)
var _generation_queue  : Array[Vector2] = []
var _ready_done        := false
var _noise             := FastNoiseLite.new()
var _warp_noise        := FastNoiseLite.new()

# ─────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────

func _ready() -> void:
	_setup_noise()
	_ready_done = true
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.timeout.connect(_on_tick)
	timer.start()
	print("ready")

func _on_tick() -> void:
	PlayerManager.biome_in.emit(get_player_biome())

func _process(_delta: float) -> void:
	if not _ready_done:
		return

	var player := _get_player()
	if not player:
		return

	var player_chunk := _world_to_chunk(player.global_position)

	if player_chunk != _last_player_chunk:
		_last_player_chunk = player_chunk
		_queue_visible_chunks(player_chunk)
		_unload_distant_chunks(player_chunk)
		PlayerManager.player_changed_chunk.emit()

	for i in range(CHUNKS_PER_FRAME):
		if _generation_queue.is_empty():
			break
		_generate_chunk(_generation_queue.pop_front())

# ─────────────────────────────────────────
#  Noise Setup
# ─────────────────────────────────────────

func _setup_noise() -> void:
	_noise.noise_type         = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.seed               = randi()
	_noise.frequency          = 0.0001
	_noise.fractal_type       = FastNoiseLite.FRACTAL_FBM
	_noise.fractal_octaves    = 5
	_noise.fractal_lacunarity = 2.0
	_noise.fractal_gain       = 0.5

	_warp_noise.noise_type      = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_warp_noise.seed            = _noise.seed + 1
	_warp_noise.frequency       = 0.01
	_warp_noise.fractal_octaves = 2

# ─────────────────────────────────────────
#  Chunk Queuing
# ─────────────────────────────────────────

func _queue_visible_chunks(player_chunk: Vector2) -> void:
	_generation_queue.clear()

	var to_queue : Array[Vector2] = []

	for x in range(-VIEW_DISTANCE, VIEW_DISTANCE + 1):
		for y in range(-VIEW_DISTANCE, VIEW_DISTANCE + 1):
			var coord := player_chunk + Vector2(x, y)
			if _active_chunks.has(coord):
				continue
			to_queue.append(coord)

	to_queue.sort_custom(func(a, b):
		return a.distance_squared_to(player_chunk) < b.distance_squared_to(player_chunk)
	)

	_generation_queue = to_queue

func _unload_distant_chunks(player_chunk: Vector2) -> void:
	_generation_queue = _generation_queue.filter(func(coord):
		return coord.distance_to(player_chunk) <= VIEW_DISTANCE + UNLOAD_MARGIN
	)

	var to_remove : Array[Vector2] = []
	for coord in _active_chunks.keys():
		if (coord as Vector2).distance_to(player_chunk) > VIEW_DISTANCE + UNLOAD_MARGIN:
			to_remove.append(coord)

	for coord in to_remove:
		_active_chunks[coord].queue_free()
		_active_chunks.erase(coord)

# ─────────────────────────────────────────
#  Chunk Generation
# ─────────────────────────────────────────

func _generate_chunk(chunk_coord: Vector2) -> void:
	if _active_chunks.has(chunk_coord):
		return

	var image := Image.create(CHUNK_SIZE, CHUNK_SIZE, false, Image.FORMAT_RGB8)

	for px in range(CHUNK_SIZE):
		for py in range(CHUNK_SIZE):
			var world_x   : float = chunk_coord.x * CHUNK_SIZE + px
			var world_y   : float = chunk_coord.y * CHUNK_SIZE + py
			var noise_val : float = _noise.get_noise_2d(world_x, world_y) * 0.5 + 0.5
			var warp      : float = _warp_noise.get_noise_2d(world_x, world_y) * 0.001
			var warped    : float = clamp(noise_val + warp, 0.0, 1.0)
			image.set_pixel(px, py, _noise_to_color(warped))

	var texture := ImageTexture.create_from_image(image)

	var chunk             := Sprite2D.new()
	chunk.texture         = texture
	chunk.centered        = true
	chunk.texture_filter  = FILTER_MODE
	chunk.global_position = ((chunk_coord * CHUNK_SIZE) + Vector2(CHUNK_SIZE, CHUNK_SIZE) * 0.5).round()

	add_child(chunk)
	_active_chunks[chunk_coord] = chunk

# ─────────────────────────────────────────
#  Biome Colours
# ─────────────────────────────────────────

func _noise_to_color(v: float) -> Color:
	var ocean          := Color(0.39, 0.68, 0.68) # #63ADAD
	var ocean_details1 := Color(0.40, 0.70, 0.66) # #66B2A9
	var ocean_details2 := Color(0.45, 0.71, 0.67) # #72B5AB
	var ocean_details3 := Color(0.49, 0.73, 0.70) # #7DBAB3
	var sand        := Color(0.94, 0.90, 0.78)
	var grass       := Color(0.33, 0.62, 0.36)

	if v < 0.38 : return ocean
	if v < 0.3 : return ocean_details1
	if v < 0.40 : return ocean_details2
	if v < 0.41 : return ocean_details3
	if v < 0.49 : return sand
	if v < 0.88 : return grass
	return grass
# ─────────────────────────────────────────
#  Helpers
# ─────────────────────────────────────────

func _world_to_chunk(world_pos: Vector2) -> Vector2:
	return Vector2(floor(world_pos.x / CHUNK_SIZE), floor(world_pos.y / CHUNK_SIZE))

func _get_player() -> Node2D:
	if PlayerManager and PlayerManager.player:
		return PlayerManager.player
	return null

# ─────────────────────────────────────────
#  Terrain Query (public API for other nodes)
# ─────────────────────────────────────────

func get_biome_at(world_pos: Vector2) -> String:
	var noise_val : float = _noise.get_noise_2d(world_pos.x, world_pos.y) * 0.5 + 0.5
	var warp      : float = _warp_noise.get_noise_2d(world_pos.x, world_pos.y) * 0.001
	var warped    : float = clamp(noise_val + warp, 0.0, 1.0)
	return _noise_to_biome(warped)

func get_player_biome() -> String:
	var player := _get_player()
	if not player:
		return "grass"
	return get_biome_at(player.global_position)

func _noise_to_biome(v: float) -> String:
	if v < 0.38: return "ocean"
	if v < 0.49: return "sand"
	if v < 0.88: return "grass"
	return "grass"

func get_chunk_size() -> int:
	return CHUNK_SIZE

func get_view_distance() -> int:
	return VIEW_DISTANCE

func get_unload_margin() -> float:
	return UNLOAD_MARGIN
