extends TextureRect

var mouse_on : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	mouse_on = true
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	print("pen")


func _on_area_2d_mouse_exited() -> void:
	mouse_on = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1., 1.), 0.1)
