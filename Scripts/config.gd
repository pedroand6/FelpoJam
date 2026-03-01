extends Control

@onready var bt_fechar := get_parent().get_node("Fechar")
@onready var vol_slider: HSlider = $Configs/Volume/VBoxContainer/HSlider
@onready var vol_soundup := $VolSoundUp
@onready var vol_sounddown := $VolSoundDown
@onready var check_tela: CheckBox = $Configs/Tela/HBoxContainer/VBoxContainer0/CheckCheia
@onready var check_sync: CheckBox = $Configs/Tela/HBoxContainer/VBoxContainer1/CheckSync
@onready var mouse_on_menu := $mousehovermenu

@onready var btn_click_sfx = $btn_click
var list_btn_click = ["res://Audio/SFX/CLIQUE BOTÕES 1.wav", "res://Audio/SFX/CLIQUE BOTÕES 2.wav"]

@export var cena_nome: String

var ult_mudan: float

func _ready():
	ult_mudan = AudioServer.get_bus_volume_linear(0)
	vol_slider.value = ult_mudan
	check_tela.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	check_sync.button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED

func _on_h_slider_value_changed(value: float) -> void:
	Gerenciador.muda_volume(value)
	if value > ult_mudan:
		vol_soundup.play()
	elif value < ult_mudan:
		vol_sounddown.play()
	ult_mudan = value

func _on_check_cheia_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on 
		else DisplayServer.WINDOW_MODE_WINDOWED
	)
	click_sfx()

func _on_check_sync_toggled(toggled_on: bool) -> void:
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if toggled_on
		else DisplayServer.VSYNC_DISABLED
	)
	click_sfx()

func _on_voltar_button_down() -> void:
	if bt_fechar: bt_fechar.emit_signal("button_down")
	click_sfx()

func _on_sair_button_down() -> void:
	click_sfx()
	Gerenciador.muda_cena(cena_nome, "res://Scenes/menu.tscn")

func _on_check_cheia_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_check_sync_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_voltar_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_sair_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_h_slider_mouse_entered() -> void:
	mouse_on_menu.play()

func click_sfx():
	btn_click_sfx.stream = load(list_btn_click[randi() % 2])
	btn_click_sfx.play()
