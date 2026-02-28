extends Control

@onready var mouse_on_menu = $mousehovermenu

func _on_fechar_button_down() -> void:
	Gerenciador.muda_cena("Creditos", "res://Scenes/menu.tscn")


func _on_fechar_mouse_entered() -> void:
	mouse_on_menu.play()
