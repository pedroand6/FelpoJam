extends Node3D
class_name CardGame

const JOGADOR = 0
const IA = 1

@onready var ia = $Inimigo
@onready var mouse_on_menu = $mousehovermenu

@export var jogador_carimbo := Gerenciador.Carimbos.BASICO
@export var ia_carimbo := Gerenciador.Carimbos.BRINQUEDO

signal cartas_prontas
signal passou_turno

func _ready() -> void:
	Gerenciador.ia_carimbo = ia_carimbo
	Gerenciador.jogador_carimbo = jogador_carimbo
	Gerenciador.set_carimbos()
	cartas_prontas.emit()

func passa_round():
	Gerenciador.round += 1
	Gerenciador.round_muda.emit()
	
func passa_turno(player : int):
	if player == JOGADOR and Gerenciador.turno == JOGADOR:
		passou_turno.emit()
		Gerenciador.turno = IA
		ia.jogada()
	elif player == IA and Gerenciador.turno == IA: 
		Gerenciador.turno = JOGADOR
		Gerenciador.desbloqueia_jogar()
		passa_round()

func _on_pular_btn_button_down() -> void:
	passa_turno(JOGADOR)

func _on_inimigo_passa_turno() -> void:
	passa_turno(IA)


func _on_sim_btn_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_nao_btn_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_fechar_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_demissao_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_prancheta_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_info_btn_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_config_btn_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_descarte_btn_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_pular_btn_mouse_entered() -> void:
	mouse_on_menu.play()

func _on_baralho_mouse_entered() -> void:
	mouse_on_menu.play()
