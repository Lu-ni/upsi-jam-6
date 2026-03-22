extends Node2D

# ─────────────────────────────────────────
#  Configuration
# ─────────────────────────────────────────

const LOOKUP_SIZE     := 300
const CIRCLE_RADIUS   := int(LOOKUP_SIZE * 2)
const SEARCH_RADIUS   := 2000
const SEARCH_ATTEMPTS := 500

const DROP_MAX_RADIUS       := CIRCLE_RADIUS * 3
const DROP_SPAWN_CHANCE_MIN := 0.0    # probability right at the heap
const DROP_SPAWN_CHANCE_MAX := 0.35   # probability at DROP_MAX_RADIUS and beyond

const SHOP_SCENE            := preload("res://scenes/Shop.tscn")
const CRAFT_SCENE           := preload("res://scenes/Craft.tscn")
const HEAP_OF_GARBAGE_SCENE := preload("res://scenes/HeapOfGarbage.tscn")
const DROP_SCENE            := preload("res://scenes/Drop.tscn")

# ─────────────────────────────────────────
#  State
# ─────────────────────────────────────────

var _world_map     : Node    = null
var _marker        : Node2D  = null
var _base_spot     : Vector2 = Vector2.INF
var _spawned_chunks : Dictionary = {}   # chunk_coord -> true, never re-seeded

# ─────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────

func _ready() -> void:
	call_deferred("_init_spawner")

func _init_spawner() -> void:
	_world_map = get_tree().root.find_child("WorldMap", true, false)
	if not _world_map:
		push_error("BaseSpawner: could not find 'WorldMap'.")
		return
	print("BaseSpawner: WorldMap found -> ", _world_map.name)

	await get_tree().process_frame

	print("BaseSpawner: player -> ", _get_player())

	_base_spot = _find_grass_spot()
	print("BaseSpawner: spot found -> ", _base_spot)

	if _base_spot == Vector2.INF:
		push_error("BaseSpawner: no pure-grass spot found after %d attempts." % SEARCH_ATTEMPTS)
		return

	_draw_marker(_base_spot)
	_spawn_scenes(_base_spot)
	_teleport_player(_base_spot)

	# Wait one frame so the player has moved and WorldMap has emitted its first
	# player_changed_chunk — then connect so every future chunk crossing seeds drops.
	await get_tree().process_frame
	PlayerManager.player_changed_chunk.connect(_on_player_changed_chunk)
	# Seed the initial visible area straight away.
	_spawn_drops()

# ─────────────────────────────────────────
#  Signal handler
# ─────────────────────────────────────────

func _on_player_changed_chunk() -> void:
	_spawn_drops()

# ─────────────────────────────────────────
#  Search
# ─────────────────────────────────────────

func _find_grass_spot() -> Vector2:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for i in range(SEARCH_ATTEMPTS):
		var candidate := Vector2(
			rng.randf_range(-SEARCH_RADIUS, SEARCH_RADIUS),
			rng.randf_range(-SEARCH_RADIUS, SEARCH_RADIUS)
		)
		if _is_all_grass(candidate):
			return candidate

	return Vector2.INF

func _is_all_grass(center: Vector2) -> bool:
	var step := 4
	var half  := LOOKUP_SIZE
	for dx in range(-half, half + 1, step):
		for dy in range(-half, half + 1, step):
			if _world_map.get_biome_at(center + Vector2(dx, dy)) != "grass":
				return false
	return true

# ─────────────────────────────────────────
#  Scene Spawning
# ─────────────────────────────────────────

func _spawn_scenes(spot: Vector2) -> void:
	var heap := HEAP_OF_GARBAGE_SCENE.instantiate()
	heap.global_position = spot
	add_child(heap)
	print("BaseSpawner: HeapOfGarbage spawned at ", spot)

	var shop := SHOP_SCENE.instantiate()
	shop.global_position = spot + Vector2(CIRCLE_RADIUS, 0)
	add_child(shop)
	print("BaseSpawner: Shop spawned at ", shop.global_position)

	var craft := CRAFT_SCENE.instantiate()
	craft.global_position = spot + Vector2(-CIRCLE_RADIUS, 0)
	add_child(craft)
	print("BaseSpawner: Craft spawned at ", craft.global_position)

# ─────────────────────────────────────────
#  Drop Spawning  (called every chunk crossing)
# ─────────────────────────────────────────

func _spawn_drops() -> void:
	var player := _get_player()
	if not player:
		return

	var chunk_size : int = _world_map.get_chunk_size()
	var view_dist  : int = _world_map.get_view_distance()
	var rng        := RandomNumberGenerator.new()
	rng.randomize()

	# Centre the scan on the PLAYER's current chunk so newly loaded
	# chunks at the edge of view are always covered.
	var player_chunk := Vector2(
		floor(player.global_position.x / chunk_size),
		floor(player.global_position.y / chunk_size)
	)

	var total := 0

	for cx in range(-view_dist, view_dist + 1):
		for cy in range(-view_dist, view_dist + 1):
			var chunk_coord  := player_chunk + Vector2(cx, cy)

			# Never re-seed a chunk we already visited.
			if _spawned_chunks.has(chunk_coord):
				continue
			_spawned_chunks[chunk_coord] = true

			var chunk_world  := chunk_coord * chunk_size
			var chunk_center := chunk_world + Vector2(chunk_size, chunk_size) * 0.5

			# Distance from this chunk to the HEAP (not the player).
			var dist := chunk_center.distance_to(_base_spot)

			# Linear ramp 0→MAX up to DROP_MAX_RADIUS, flat cap beyond.
			var t      := minf(dist / float(DROP_MAX_RADIUS), 1.0)
			var chance := lerpf(DROP_SPAWN_CHANCE_MIN, DROP_SPAWN_CHANCE_MAX, t)

			if rng.randf() > chance:
				continue

			# One candidate position per chunk, random inside the chunk.
			var candidate := Vector2(
				chunk_world.x + rng.randf_range(0.0, float(chunk_size)),
				chunk_world.y + rng.randf_range(0.0, float(chunk_size))
			)

			var biome : String = _world_map.get_biome_at(candidate)
			if biome == "ocean":
				continue

			# Sand spawns freely; grass is rarer.
			if biome == "grass" and rng.randf() < 0.6:
				continue

			var drop := DROP_SCENE.instantiate()
			drop.global_position = candidate
			add_child(drop)
			total += 1

# ─────────────────────────────────────────
#  Marker Drawing
# ─────────────────────────────────────────

func _draw_marker(world_pos: Vector2) -> void:
	if _marker:
		_marker.queue_free()

	_marker = Node2D.new()
	_marker.position = world_pos
	add_child(_marker)

	var canvas := _MarkerCanvas.new()
	canvas.circle_radius = CIRCLE_RADIUS
	canvas.position = Vector2.ZERO
	_marker.add_child(canvas)
	canvas.queue_redraw()

	print("BaseSpawner: marker placed at ", world_pos)

# ─────────────────────────────────────────
#  Player
# ─────────────────────────────────────────

func _teleport_player(world_pos: Vector2) -> void:
	var player := _get_player()
	if player:
		player.global_position = world_pos
		print("BaseSpawner: player teleported to ", world_pos)
	else:
		push_error("BaseSpawner: player is null, cannot teleport.")

func _get_player() -> Node2D:
	if PlayerManager and PlayerManager.player:
		return PlayerManager.player
	return null

# ─────────────────────────────────────────
#  Inner draw class
# ─────────────────────────────────────────

class _MarkerCanvas extends Node2D:
	var circle_radius : int = 30

	func _draw() -> void:
		var r   := float(circle_radius)
		var col := Color(1, 0, 0, 0.0)
		var rim := Color(1, 0, 0, 1.0)
		draw_circle(Vector2.ZERO, r, col)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, rim, 2.0)
