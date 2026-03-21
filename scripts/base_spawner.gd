extends Node2D

# ─────────────────────────────────────────
#  Configuration
# ─────────────────────────────────────────

const LOOKUP_SIZE     := 500
const SEARCH_RADIUS   := 2000
const SEARCH_ATTEMPTS := 500

# ─────────────────────────────────────────
#  State
# ─────────────────────────────────────────

var _world_map : Node = null
var _marker    : Node2D = null

# ─────────────────────────────────────────
#  Lifecycle
# ─────────────────────────────────────────

func _ready() -> void:
	# Defer so WorldMap and PlayerManager are fully initialized
	call_deferred("_init_spawner")

func _init_spawner() -> void:
	_world_map = get_tree().root.find_child("WorldMap", true, false)
	if not _world_map:
		push_error("GrassSpotFinder: could not find 'WorldMap'.")
		return
	print("GrassSpotFinder: WorldMap found -> ", _world_map.name)

	# Wait one extra frame for PlayerManager.player to be set
	await get_tree().process_frame

	var player := _get_player()
	print("GrassSpotFinder: player -> ", player)

	var spot := _find_grass_spot()
	print("GrassSpotFinder: spot found -> ", spot)

	if spot == Vector2.INF:
		push_error("GrassSpotFinder: no pure-grass spot found after %d attempts." % SEARCH_ATTEMPTS)
		return

	_draw_marker(spot)
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
			print("GrassSpotFinder: attempt %d candidate=%s biome=%s" % [i, candidate, biome])
		if _is_all_grass(candidate):
			return candidate

	return Vector2.INF

func _is_all_grass(center: Vector2) -> bool:
	var step := 10
	var half  := LOOKUP_SIZE
	for dx in range(-half, half + 1, step):
		for dy in range(-half, half + 1, step):
			if _world_map.get_biome_at(center + Vector2(dx, dy)) != "grass":
				return false
	return true

# ─────────────────────────────────────────
#  Marker Drawing
# ─────────────────────────────────────────

func _draw_marker(world_pos: Vector2) -> void:
	if _marker:
		_marker.queue_free()

	_marker = Node2D.new()
	_marker.global_position = world_pos
	add_child(_marker)
	print("GrassSpotFinder: marker placed at ", world_pos)

	var canvas := _MarkerCanvas.new()
	canvas.lookup_size = LOOKUP_SIZE
	_marker.add_child(canvas)

func _teleport_player(world_pos: Vector2) -> void:
	var player := _get_player()
	if player:
		player.global_position = world_pos
		print("GrassSpotFinder: player teleported to ", world_pos)
	else:
		push_error("GrassSpotFinder: player is null, cannot teleport.")

func _get_player() -> Node2D:
	if PlayerManager and PlayerManager.player:
		return PlayerManager.player
	return null

# ─────────────────────────────────────────
#  Inner draw class
# ─────────────────────────────────────────

class _MarkerCanvas extends Node2D:
	var lookup_size : int = 5

	func _draw() -> void:
		var r   := float(lookup_size)
		var col := Color(1, 0, 0, 0.45)
		var rim := Color(1, 0, 0, 1.0)
		draw_circle(Vector2.ZERO, r, col)
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, rim, 2.0)
