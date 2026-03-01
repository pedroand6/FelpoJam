extends Control

const parallax_1: float = 1.0
const parallax_2: float = 2.0
const parallax_attenuation: float = 75.0

@onready var menu := $Menu
@onready var opts := $Opts
@onready var vol_slider: HSlider = $Opts/Volume/VBoxContainer/HSlider
@onready var check_tela: CheckBox = $Opts/VBoxContainer0/CheckCheia
@onready var check_sync: CheckBox = $Opts/VBoxContainer1/CheckSync
@onready var init_sound := $IniciarSound
@onready var vol_soundup := $VolSoundUp
@onready var vol_sounddown := $VolSoundDown
@onready var fade_out := $FadeOut
@onready var mouse_on_menu = $mousehovermenu

@onready var btn_click_sfx = $btn_click
var list_btn_click = ["res://Audio/SFX/CLIQUE BOTÕES 1.wav", "res://Audio/SFX/CLIQUE BOTÕES 2.wav"]

@onready var fundo := $fundo
@onready var contrato := $contrato
@onready var mao := $mao

var ult_mudan: float

func _ready() -> void:
	if get_tree().paused: get_tree().paused = false
	Gerenciador.set_script(null)
	Gerenciador.set_script(preload("res://Scripts/gerenciador_jogo.gd"))
	ult_mudan = AudioServer.get_bus_volume_linear(0)
	vol_slider.value = ult_mudan
	check_tela.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	check_sync.button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
#		contrato.position += event.relative * parallax_1 / parallax_attenuation
		mao.position += event.relative * parallax_2 / parallax_attenuation

func _on_iniciar_button_down() -> void:
	init_sound.play()
	fade_out.show()
	await fade_out.fade(1.0)
	Gerenciador.muda_cena("Menu", "res://Scenes/VisualNovel.tscn")

func _on_opt_button_down() -> void:
	opts.show()
	menu.hide()
	click_sfx()

func _on_cred_button_down() -> void:
	click_sfx()
	Gerenciador.muda_cena("Menu", "res://Scenes/creditos.tscn")

func _on_sair_button_down() -> void:
	click_sfx()
	get_tree().quit()

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
	menu.show()
	opts.hide()
	click_sfx()

func _on_h_slider_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_check_cheia_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_check_sync_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_voltar_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_sair_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_cred_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_opt_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_iniciar_mouse_entered() -> void:
	mouse_on_menu.play()

func click_sfx():
	btn_click_sfx.stream = load(list_btn_click[randi() % 2])
	btn_click_sfx.play()
