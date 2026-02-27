extends Node3D

@export var time: float = 1.0

var quant: int = 0
@onready var label: Label3D = $Label3D

func _ready() -> void:
	label.modulate = Color(255.0, 255.0, 255.0)

func sumir() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "modulate:a", 0.0, time)
	tween.tween_property(label, "position", position + Vector3(0, 1.0, 0), time)
	await tween.finished
	queue_free()
