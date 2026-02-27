extends Node3D

enum Players {
	JOGADOR = 0,
	IA = 1,
	NENHUM = 2
}

@onready var borda = $Borda
var mouse_on := false

var dono : Players = Players.NENHUM
var bloqueada : bool = false

var funcionarios : Array[Contrato]
var demandas : Array[Contrato]

#Pontuação
var multiplicador := 1
var incrementador := 0
var pontuacao := 0

@onready var mao = $"../../Camera3D/3DUI/Mao"
@onready var escritorio = $"../.."
@onready var ui = $"../../UI"
@onready var dinheiro: PackedScene = load("res://Scenes/dinheiro.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Gerenciador.comeca_turno.connect(implementa_pontos)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouse_on and len(Gerenciador.cartas_selecionadas) <= 0:
			open_room()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouse_on and not bloqueada:
			insert_cartas_player()

func open_room():
	var func_imagens = []
	var utils = []
	for fun in funcionarios:
		func_imagens.append(fun.sprite)
	
	for util in demandas:
		utils.append(util.nome + ": " + util.desc)
		
	ui.set_cartas(func_imagens)
	ui.set_utilitarios(utils)
	ui.set_combo(Gerenciador.combos[multiplicador][0], Gerenciador.combos[multiplicador][1])
	
	var donoSala
	match dono:
		Players.JOGADOR:
			donoSala = "Sua sala"
		Players.IA:
			donoSala = "Sala inimiga"
		Players.NENHUM:
			donoSala = "Sala sem dono"
	
	ui.show_sala(donoSala, pontuacao)

func insert_cartas_player():
	if dono == Players.IA: return #avisar jogador
	
	var quantFunc = 0
	var quantDemanda = 0
	var custo = 0
	
	for carta in Gerenciador.cartas_selecionadas:
		var contrato = carta.contrato
		custo += contrato.custo
		if contrato.tipo == Contrato.Tipos.FUNCIONARIO:
			quantFunc += 1
		else:
			quantDemanda += 1
	
	if quantFunc + len(funcionarios) > 4: return #avisar jogador
	if quantDemanda + len(demandas) > 3: return #avisar jogador
	if custo > Gerenciador.jogador_dinheiro: return #avisar jogador
	
	Gerenciador.jogador_dinheiro -= custo
	
	for carta in Gerenciador.cartas_selecionadas:
		var contrato = carta.contrato
		if contrato.tipo == Contrato.Tipos.FUNCIONARIO:
			funcionarios.append(contrato)
		else:
			demandas.append(contrato)
	
	dono = Players.JOGADOR
	mao.descarta(false)
	calcula_pontos()

func calcula_pontos():
	for funcionario in funcionarios:
		incrementador += funcionario.produtividade
		
	multiplicador = Gerenciador.calcula_combo(funcionarios)
	pontuacao = multiplicador * incrementador

func implementa_pontos():
	match dono:
		Players.JOGADOR:
			Gerenciador.jogador_dinheiro += int(pontuacao / 2)
			var din = dinheiro.instantiate()
			add_child(din)
			din.label.text = "R$"+str(int(pontuacao/2))
			din.position = Vector3.ZERO
			din.sumir()
		Players.IA:
			Gerenciador.IA_dinheiro += int(pontuacao / 2)

func _on_area_3d_mouse_entered() -> void:
	borda.show()
	mouse_on = true

func _on_area_3d_mouse_exited() -> void:
	borda.hide()
	mouse_on = false
