extends Node3D
class_name Mao

#TODO: animation on draw
#card spacing
#card sprite by rank + area
#add cards weights

const TAMANHO_MAO: int = 7
#0, -0.115, -0.2
const CARTA_POS_BASE: Vector3 = Vector3(0, -0.11, -0.2)
const VELOCIDADE_MOVIMENTO: float = 0.01

#const CAMINHO_IMG_FI_DONO: String = "res://Assets/coringa.png"

const ESPACAMENTO_X: float = 0.026 #0.023
const ESPACAMENTO_Y: float = -0.001
const ROTACAO_CARTAS: float = 1.0

var tamanho_mao: int = 0
var cartas_mao: Array[Node3D]

@onready var node_carta = preload("res://Scenes/carta.tscn")
@onready var descarte_sfx = $descarte

func _ready():
	Gerenciador.comeca_turno.connect(player_comecou_turno)

func comprar_mao():
	while tamanho_mao < TAMANHO_MAO:
		if(len(Gerenciador.jogador_baralho) <= 0): break
		compra_uma()

func compra_uma():
	var carta_topo: Contrato = Gerenciador.jogador_baralho.pop_back()
	var instance = node_carta.instantiate()
	
	instance.canAnimate = false
	instance.contrato = carta_topo
	instance.position = CARTA_POS_BASE
	
	cartas_mao.append(instance)
	tamanho_mao += 1
	
	posiciona_cartas()
	
	add_child(instance)
	Gerenciador.jogador_baralho_pego.append(carta_topo)
	Gerenciador.compra_carta.emit(carta_topo)

func posiciona_cartas():
	for i in range(tamanho_mao):
		cartas_mao[i].canAnimate = false
		cartas_mao[i].position.x = CARTA_POS_BASE.x + -2 * ESPACAMENTO_X * i \
		+ ESPACAMENTO_X * (tamanho_mao - 1)
		
		cartas_mao[i].position.y = CARTA_POS_BASE.y + ESPACAMENTO_Y * ((i - 0.5 * \
		tamanho_mao + 1.5)**2 - 2*(i - 0.5 * tamanho_mao + 1.5) + 1)
		
		cartas_mao[i].rotation_degrees.z = 2 * ROTACAO_CARTAS * i - ROTACAO_CARTAS * (tamanho_mao - 1)
		
func _on_escritorio_cartas_prontas() -> void:
	comprar_mao()

func _on_descarte_btn_button_down() -> void:
	descarta(true)

func descarta(compra : bool):
	var selecionadas = Gerenciador.cartas_selecionadas.duplicate()
	if (Gerenciador.descartes_restantes - len(selecionadas)) < 0 and compra: 
		return
	
	if compra:
		for carta in Gerenciador.cartas_selecionadas:
			descarte_sfx.play()
			var tw = create_tween()
			tw.tween_property(carta, "position", Vector3(10.0, carta.position.y, carta.position.z), 2.0)
			await descarte_sfx.finished
	
	var quantidade = len(selecionadas)
	for carta in selecionadas:
		Gerenciador.descarte(carta, Gerenciador.jogador_baralho)
		
	for carta in selecionadas:
		if compra: 
			Gerenciador.descartes_restantes -= 1
		cartas_mao.erase(carta)
	
	tamanho_mao = len(cartas_mao)
	Gerenciador.cartas_selecionadas.clear()
	selecionadas.clear()
	
	if compra:
		for i in range(quantidade):
			compra_uma()
	
	posiciona_cartas()

func player_comecou_turno():
	comprar_mao()
