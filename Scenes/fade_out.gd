extends ColorRect

func _ready() -> void:
	color.a = 0

func fade(time: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "color:a", 1.0, time)
	await tween.finished
