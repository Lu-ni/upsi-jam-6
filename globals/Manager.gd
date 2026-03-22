extends Node

var in_game: bool = false
var hud: Node = null
var menu: Node = null
var world: Node = null
var pause_menu: Node = null
var end_menu: Node = null
var music: AudioStreamPlayer2D = null

var paused: bool = false

var mute: bool = false
var track = 0
var tracks: Array[String] = [
	"res://assets/audio/music/Thief's groove.mp3",
	"res://assets/audio/music/Goofy goober.mp3",
	"res://assets/audio/music/Cheeky chase.mp3",
	"res://assets/audio/music/Garbage groove.mp3",
	"res://assets/audio/music/Racoon's play.mp3",
]

var initialized: bool = false

func _process(delta: float) -> void:
	if not initialized:
		music = AudioStreamPlayer2D.new()
		music.max_distance = 100000
		get_tree().root.add_child(music)
		music.finished.connect(play_next_track)
		pause_menu = load("res://scenes/pause_menu.tscn").instantiate()
		hud = load("res://scenes/HUD.tscn").instantiate()
		end_menu = load("res://scenes/end_menu.tscn").instantiate()
		get_tree().root.add_child(hud)
		get_tree().root.add_child(end_menu)
		get_tree().root.add_child(pause_menu)
		hud.visible = false
		end_menu.visible = false
		pause_menu.visible = false
		menu = get_tree().root.get_node("MainMenu")
		play_next_track()
		initialized = true
	if Input.is_action_just_pressed("ui_cancel") and in_game:
		paused = !paused
		pause_menu.visible = paused
		music.stream_paused = paused
		world.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_ALWAYS
		hud.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_ALWAYS
	if Input.is_action_just_pressed("next_track"):
		play_next_track()
	if Input.is_action_just_pressed("mute"):
		mute = !mute
		if mute: music.stop()
		else: music.play()

func _ready() -> void:
	pass

func toggle_pause_menu():
	pass

func start_game():
	reset_game_data()
	world = load("res://scenes/World.tscn").instantiate()
	add_sibling(world)
	hud.visible = true
	menu.visible = false
	end_menu.visible = false
	in_game = true

func return_to_menu():
	if world != null:
		world.queue_free()
	hud.visible = false
	menu.visible = true
	end_menu.visible = false
	in_game = false

func go_to_end_menu():
	if world != null:
		world.queue_free()
	hud.visible = false
	end_menu.update()
	end_menu.visible = true
	in_game = false

func reset_game_data():
	GameInfo.throw_trash_time = BaseDataValues.base_throw_trash_time
	GameInfo.amount_of_trash_collected = BaseDataValues.base_amount_of_trash_collected
	GameInfo.has_seen_craft_tuto = false
	GameInfo.has_seen_shop_tuto = false
	GameInfo.time_left = BaseDataValues.base_max_time
	GameInfo.total_time = 0
	GameInfo.score = 0
	GameInfo.multiplier = 1
	GameInfo.HOWMUCHTRASHFORMULTUP = BaseDataValues.base_HOWMUCHTRASHFORMULTUP
	
	PlayerInfo.inventory = []
	PlayerInfo.max_inventory = BaseDataValues.base_max_inventory
	
	Signals.inventory_updated.emit()

func play_next_track():
	track = (track + 1) % tracks.size()
	music.stream = load(tracks[track])
	music.play()
