extends Node2D

export var game_started := false
export var ground_tilemap: PackedScene

onready var timer: Timer = $Timer
onready var black_screen: Control = $GameLayer/BlackScreen
onready var player = $Player
onready var ground_tile = $"%Ground"
onready var game_over_screen = $GameLayer/GameOver
onready var label_score: Label = $GameLayer/GameOver/LabelScore
onready var label_last_stop: Label = $GameLayer/LastStop

const WAIT_TIME = 10.0
const STOP_TEXT = "Last stop: -"

var player_stop_time := 0.0
var last_player_stop_time := WAIT_TIME
var ground: Node2D = null

func _ready() -> void:
	ground_tile.connect("spawn_tilemap", self, "on_GroundTile_spawn")
	player.connect("first_move", self, "on_Player_first_move")
	if !game_started:
		timer.stop()
		return
	else:
		start_game()
		
func _process(delta: float) -> void:
	if game_over_screen.visible && Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
	if black_screen.visible && player.is_moving && !game_over_screen.visible:
		game_over()
	
func start_game() -> void:
	timer.connect("timeout", self, "on_Timer_timeout")
	player.connect("player_stopped", self, "on_Player_stopped")
	timer.start(WAIT_TIME)
	game_started = true
	
func check_game_over() -> void:
	print("Player is moving: ", player.is_moving)
	print("Player stopped at: ", player_stop_time)	
	print("Last stopped at: ", last_player_stop_time)	
	if !player.is_moving:
		if player_stop_time < last_player_stop_time:
			last_player_stop_time = player_stop_time
			label_last_stop.text = STOP_TEXT.replace("-", str(last_player_stop_time))
			var wait := randf() * 2.0
			timer.start(wait)
		else:
			game_over()
	else:
		game_over()

func game_over() -> void:
	timer.stop()
	game_over_screen.visible = true
	player.can_move = false
	label_score.text = label_score.text % str(stepify(player.steps / 60.0, 0.01))
	print("Total steps:", player.steps)
	
func on_Timer_timeout() -> void:
	black_screen.visible = !black_screen.visible
	if (black_screen.visible):
		check_game_over()
	else:
		timer.start(WAIT_TIME)
		
func on_Player_stopped() -> void:
	player_stop_time = timer.time_left
	
func on_GroundTile_spawn(position: Vector2) -> void:
	if ground:
		ground.disconnect("spawn_tilemap", self, "on_GroundTile_spawn")
	ground = ground_tilemap.instance()
	ground.connect("spawn_tilemap", self, "on_GroundTile_spawn")
	ground.position = position
	add_child(ground)
	print("Spawn tile at position: ", position)
	
func on_Player_first_move() -> void:
	print("First move")
	start_game()	
	
