extends Node3D
class_name CardGame

const JOGADOR = 0
const IA = 1

@onready var ia = $Inimigo
@onready var mouse_on_menu = $mousehovermenu
@onready var ui = $UI
@onready var mao = $Camera3D/Mao

@export var jogador_carimbo := Gerenciador.Carimbos.BASICO
@export var ia_carimbo := Gerenciador.Carimbos.BRINQUEDO

@export var turnos_totais := 8

signal cartas_prontas
signal passou_turno

func _ready() -> void:
	if get_tree().paused: get_tree().paused = false
	Gerenciador.total_rounds = turnos_totais
	Gerenciador.turno = Gerenciador.JOGADOR
	Gerenciador.round = 1
	Gerenciador.IA_dinheiro = 150
	Gerenciador.jogador_dinheiro = 150
	Gerenciador.descartes_restantes = 4
	Gerenciador.derrota.connect(perdeu_jogo)
	
	Gerenciador.ia_carimbo = ia_carimbo
	Gerenciador.jogador_carimbo = jogador_carimbo
	Gerenciador.set_carimbos()
	cartas_prontas.emit()
	
func perdeu_jogo():
	ui.show_notificacao("Você perdeu o jogo.", Color.RED)

func passa_round():
	Gerenciador.round += 1
	Gerenciador.round_muda.emit()
	
func passa_turno(player : int):
	if player == JOGADOR and Gerenciador.turno == JOGADOR:
		Gerenciador.cartas_selecionadas.clear()
		mao.posiciona_cartas()
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
