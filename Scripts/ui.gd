extends CanvasLayer

const TRUTH: bool = true

@onready var popup_bg := %Popup
@onready var popup_box := $Popup/Caixa
@onready var baralho_list := $Popup/Caixa/Frente/Baralho
@onready var config_menu := $Popup/Caixa/Frente/Config

var baralho_show: bool = false
var config_show: bool = false

func _on_baralho_button_down() -> void:
	popup_bg.show()
	popup_box.show()
	baralho_list.show()
	baralho_show = true

func _on_config_btn_button_down() -> void:
	popup_bg.show()
	popup_box.show()
	config_menu.show()
	config_show = true

func _on_resumir_button_down() -> void:
	_on_fechar_button_down()

func _on_configuracoes_button_down() -> void:
	pass # Replace with function body.

func _on_sair_button_down() -> void:
	get_tree().quit()

func _on_fechar_button_down() -> void:
	popup_bg.hide()
	popup_box.hide()
	match TRUTH:
		baralho_show:
			baralho_show = false
			baralho_list.hide()
		config_show:
			config_show = false
			config_menu.hide()
		_:
			pass
