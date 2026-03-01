extends Control

@onready var mouse_on_menu = $mousehovermenu

@onready var btn_click_sfx = $btn_click
var list_btn_click = ["res://Audio/SFX/CLIQUE BOTÕES 1.wav", "res://Audio/SFX/CLIQUE BOTÕES 2.wav"]

func _on_fechar_button_down() -> void:
	Gerenciador.muda_cena("Creditos", "res://Scenes/menu.tscn")
	click_sfx()

func _on_fechar_mouse_entered() -> void:
	mouse_on_menu.play()

func click_sfx():
	btn_click_sfx.stream = load(list_btn_click[randi() % 2])
	btn_click_sfx.play()
