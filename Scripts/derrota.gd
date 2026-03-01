extends Control

@onready var carimbo := $TextureRect

@onready var carimbo_sfx := $carimbo
@onready var mouse_hover := $mouse_hover

var screen: Vector2 = Vector2(1920, 1080)

func _ready() -> void:
	carimbo.scale = Vector2(25, 25)
	await get_tree().create_timer(0.2).timeout
	var tween = create_tween()
	tween.tween_property(carimbo, "scale", Vector2(1,1), 2)
	await tween.finished
	carimbo_sfx.play()

func _on_button_1_button_down() -> void:
	if Gerenciador.cena == 3:
		Gerenciador.muda_cena("Derrota", "res://Scenes/escritorio.tscn")
		return
	Gerenciador.muda_cena("Derrota", "res://Scenes/tutorial.tscn")

func _on_button_2_button_down() -> void:
	Gerenciador.muda_cena("Derrota", "res://Scenes/menu.tscn")

func _on_button_1_mouse_entered() -> void:
	mouse_hover.play()

func _on_button_2_mouse_entered() -> void:
	mouse_hover.play()
