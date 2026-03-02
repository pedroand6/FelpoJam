extends Node3D

@export var time: float = 1.0

var quant: int = 0
@onready var label: Label3D = $Label3D

func _ready() -> void:
	label.modulate = Color(0.173, 0.58, 0.18, 1.0)

func sumir() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector3(1.2, 1.2, 1.2), time)
	tween.tween_property(label, "position", position + Vector3(0, 0.2, 0), time).set_ease(tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property(label, "modulate:a", 0.0, time / 2)
	await tween.finished
	queue_free()
