extends Node3D

#TODO: animation on draw
#card spacing
#card sprite by rank + area
#add cards weights

const TAMANHO_MAO: int = 7
#const MAOS: int = -1
const DESCARTES: int = 1 #descartes por round
const ESCOLHAS: int = 4 #cartas por descarte

const CARTA_POS_BASE: Vector3 = Vector3(0, -0.122, -0.2)
const VELOCIDADE_MOVIMENTO: float = 0.01

#const CAMINHO_IMG_FI_DONO: String = "res://Assets/coringa.png"

const ESPACAMENTO: float = 0.025

var tamanho_mao: int = 0
var cartas_mao: Array[Node3D]

@onready var node_carta = preload("res://Scenes/carta.tscn")

func _ready():
	comprar_mao()

func comprar_mao():
	while tamanho_mao < TAMANHO_MAO:
		compra_uma()

func compra_uma():
	var carta_topo: Carta = Gerenciador.pilha_carta.pop_back()
	
	var instance = node_carta.instantiate()
	instance.cargo = carta_topo.cargo
	instance.area = carta_topo.area
	instance.coringa = carta_topo.coringa
	#if not instance.coringa: #and not util
	#	instance.imagem = "res://Assets/" + str(instance.area) + "_" + str(instance.cargo) + ".png"
	#if instance.coringa:
	#	instance.imagem.texture = load(CAMINHO_IMG_FI_DONO)
	instance.position = CARTA_POS_BASE
	
	for carta in cartas_mao:
		carta.position.x -= ESPACAMENTO
	
	var pos_final = CARTA_POS_BASE
	if len(cartas_mao) > 0:
		var ultima = cartas_mao.back()
		pos_final.x = ultima.position.x + (2 * ESPACAMENTO)
	
	instance.position = pos_final
	
	cartas_mao.append(instance)
	tamanho_mao += 1
	
	add_child(instance)
	
	#while ult_carta.position != Vector3(pos_final):
	#	move_toward(ult_carta.position.x, pos_final.x, VELOCIDADE_MOVIMENTO)
	#	move_toward(ult_carta.position.y, pos_final.y, VELOCIDADE_MOVIMENTO)
