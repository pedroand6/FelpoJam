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

var efeitosDemandas = {
	"Cafézinho": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		for fun in funcs:
			if fun.area == "TI" or fun.area == "Financeiro":
				increm += 10
		return [increm, prod]
		,
	"Bombom da Meta": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		for fun in funcs:
			if fun.area == "RH" or fun.area == "Marketing":
				increm += 10
		return [increm, prod]
		,
	"Palestra Motivacional": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		for fun in funcs:
			if fun.cargo <= 4:
				prod += 3
		return [increm, prod]
		,
	"Dinâmicas de Grupo": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		for fun in funcs:
			if fun.cargo > 4:
				prod += 2
		return [increm, prod]
		,
	"Promoção por Mérito": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		var cargos = []
		for fun in funcs:
			cargos.append(fun.cargo)
		if 0 in cargos and 9 in cargos:
			prod *= 2
		return [increm, prod]
		,
	"Novo Time": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		if combo in [2, 3, 4, 8]:
			prod += 3
		return [increm, prod]
		,
	"Redução de Prazos": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		if combo in [3, 4, 8]:
			prod += 4
		return [increm, prod]
		,
	"Política de Diversidade": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		if combo == 8:
			prod += 6
		return [increm, prod]
		,
	"Confraternização": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		if combo in [6, 10, 12]:
			prod += 5
		return [increm, prod]
		,
	"Ar-condicionado": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		if len(funcs) == 4:
			for fun in funcs:
				prod += 1
		return [increm, prod]
		,
	"Impressora": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.area == "RH":
				prod += 2
		return [increm, prod]
		,
	"Coffee Break": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.cargo == 1:
				increm += 20
		return [increm, prod]
		,
	"Piscina de Bolinhas": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		if len(funcs) == 4:
			for fun in funcs:
				prod += 1
		return [increm, prod]
		,
	"Trabalho Remoto": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.area == "TI" or fun.area == "Marketing":
				prod += 2
		return [increm, prod]
		,
	"Chapéu de Hélice": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.cargo == 1:
				increm += 20
		return [increm, prod]
		,
	"Just-in-Time": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		if len(funcs) == 4:
			for fun in funcs:
				prod += 1
		return [increm, prod]
		,
	"Juramento à Bandeira": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.area == "RH":
				prod += 2
		return [increm, prod]
		,
	"Soldado da Produtividade": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.cargo == 1:
				increm += 20
		return [increm, prod]
}

#Pontuação
var combo := 1
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
		utils.append("- " + util.nome + ": " + util.desc)
		
	ui.set_cartas(func_imagens)
	ui.set_utilitarios(utils)
	ui.set_combo(Gerenciador.combos[combo][0], Gerenciador.combos[combo][1])
	
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
	incrementador = 0
	multiplicador = 1
	
	for funcionario in funcionarios:
		incrementador += funcionario.produtividade
		
	combo = Gerenciador.calcula_combo(funcionarios)
	multiplicador = combo
	
	for util in demandas:
		var result = efeitosDemandas[util.nome].call(funcionarios, incrementador, multiplicador, combo)
		incrementador = result[0]
		multiplicador = result[1]
	
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
