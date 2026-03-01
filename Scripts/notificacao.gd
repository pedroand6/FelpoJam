extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(5).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(queue_free)

func set_text(texto, cor := Color.WHITE):
	var textLabel : RichTextLabel = $RichTextLabel
	textLabel.text = texto
	textLabel.modulate = cor


func _on_fechar_button_down() -> void:
	queue_free()
