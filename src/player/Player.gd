extends KinematicBody2D

export var speed := 700.0
export var gravity := 30000.0
export var can_move := false

onready var sprite := $Sprite
onready var timer := $"../Timer"
onready var camera: Camera2D = $Camera2D

var first_move_done := false
var steps := 0

signal player_stopped
signal first_move

const DIRECTION_TO_FRAME := {
	Vector2.ZERO: 0,
	Vector2.RIGHT: 1,
}

var is_moving := false

func _ready() -> void:
	camera.smoothing_enabled = true

func _physics_process(delta: float) -> void:
	if !can_move:
		return
	var direction := get_direction()
	var velocity := direction * speed
	if velocity.x != 0 && !first_move_done:
		emit_signal("first_move")
		first_move_done = true
	velocity.y = gravity * delta
	if is_moving && velocity.x == 0:
		emit_signal("player_stopped")
	is_moving = velocity.x != 0
	if is_moving:
		step_count()
	move_and_slide(velocity)
	var direction_key := direction.round()
	# The abs() function makes negative numbers positive
	direction_key.x = abs(direction_key.x)
	if direction_key in DIRECTION_TO_FRAME:
		sprite.frame = DIRECTION_TO_FRAME[direction_key]
		# Notice how we directly assign the result of a comparison to flip_h. The computer converts comparisons to either true or false, which is compatible with boolean variables like flip_h.
		sprite.flip_h = sign(direction.x) == -1
		
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"), 0.0)

func step_count() -> void:
	steps += 1
	
