extends Node3D

@export var time: float = 1
var timer = 0

var quant: int = 0
var yVel
@onready var label: Label3D = $Label3D

func _ready() -> void:
	label.modulate = Color(255.0, 255.0, 255.0)
	yVel = 0.1
	
func _process(delta: float) -> void:
	timer += delta
	position += Vector3(0, yVel * timer, -0.01)
	yVel -= 0.005

func sumir() -> void:
	var tween = create_tween()
	#tween.set_parallel(true)
	#tween.tween_property(label, "position", position + Vector3(randf()*0.1, 0.3, randf()*0.1), time / 2).set_ease(tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0, time)
	await tween.finished
	queue_free()
