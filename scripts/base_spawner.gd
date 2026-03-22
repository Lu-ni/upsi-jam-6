extends Node2D

# ─────────────────────────────────────────
#  Configuration
# ─────────────────────────────────────────

const LOOKUP_SIZE     := 300
const CIRCLE_RADIUS   := LOOKUP_SIZE
const SEARCH_RADIUS   := 2000
const SEARCH_ATTEMPTS := 500
const DROP_COUNT      := 50
const DROP_SPREAD     := 400

const SHOP_SCENE            := preload("res://scenes/Shop.tscn")
const CRAFT_SCENE            := preload("res://scenes/Craft.tscn")
const HEAP_OF_GARBAGE_SCENE := preload("res://scenes/HeapOfGarbage.tscn")
const DROP_SCENE            := preload("res://scenes/Drop.tscn")

# ─────────────────────────────────────────
#  State
# ─────────────────────────────────────────

var _world_map : Node    = null
var _marker    : Node2D  = null

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

	var spot := _find_grass_spot()
	print("BaseSpawner: spot found -> ", spot)

	if spot == Vector2.INF:
		push_error("BaseSpawner: no pure-grass spot found after %d attempts." % SEARCH_ATTEMPTS)
		return

	_draw_marker(spot)
	_spawn_scenes(spot)
	_spawn_drops(spot)
	_teleport_player(spot)

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
		var biome : String = _world_map.get_biome_at(candidate)
		if i < 5:
			print("BaseSpawner: attempt %d candidate=%s biome=%s" % [i, candidate, biome])
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

	var craft := SHOP_SCENE.instantiate()
	craft.global_position = spot + Vector2(-CIRCLE_RADIUS, 0)
	add_child(craft)
	print("BaseSpawner: Shop spawned at ", shop.global_position)

func _spawn_drops(spot: Vector2) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for i in range(DROP_COUNT):
		var angle    : float = rng.randf_range(0.0, TAU)
		var distance : float = rng.randf_range(float(CIRCLE_RADIUS), float(CIRCLE_RADIUS) + DROP_SPREAD)
		var offset   := Vector2(cos(angle), sin(angle)) * distance

		var drop := DROP_SCENE.instantiate()
		drop.global_position = spot + offset
		add_child(drop)

	print("BaseSpawner: %d drops spawned around %s" % [DROP_COUNT, spot])

# ─────────────────────────────────────────
#  Marker Drawing
# ─────────────────────────────────────────

func _draw_marker(world_pos: Vector2) -> void:
	if _marker:
		_marker.queue_free()

	# Draw directly on this node so global_position is world_pos
	_marker = Node2D.new()
	_marker.position = world_pos
	add_child(_marker)

	# Use a script on the marker itself to draw
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
