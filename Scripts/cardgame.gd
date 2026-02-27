extends Node3D
class_name CardGame

const JOGADOR = 0
const IA = 1

@export var jogador_carimbo := Gerenciador.Carimbos.BASICO
@export var ia_carimbo := Gerenciador.Carimbos.BRINQUEDO

@onready var ia = $Inimigo

signal cartas_prontas
signal passou_turno

func _ready() -> void:
	Gerenciador.ia_carimbo = ia_carimbo
	Gerenciador.jogador_carimbo = jogador_carimbo
	Gerenciador.set_carimbos()
	cartas_prontas.emit()

func passa_round():
	Gerenciador.round += 1
	
func passa_turno(player : int):
	if player == JOGADOR:
		passou_turno.emit()
		Gerenciador.turno = IA
		ia.jogada()
	else: 
		Gerenciador.turno = JOGADOR
		Gerenciador.desbloqueia_jogar()
		passa_round()

func _on_pular_btn_button_down() -> void:
	passa_turno(JOGADOR)

func _on_inimigo_passa_turno() -> void:
	passa_turno(IA)
