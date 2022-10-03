extends TileMap

onready var spawn_position: Position2D = $Position2D
onready var area: Area2D = $Area2D

signal spawn_tilemap

func _on_Area2D_body_entered(body: Node) -> void:
	emit_signal("spawn_tilemap", spawn_position.global_position)
	area.queue_free()
