extends Node3D
class_name Sala

enum Players {
	JOGADOR = 0,
	IA = 1,
	NENHUM = 2
}

@export var id : int = 0
@export var vizinhos : Array[Sala]
@onready var borda := $Borda
@onready var borda2 := $Borda2
@onready var carimbo_sfx := $carimbo_sfx

var mouse_on := false

var dono : Players = Players.NENHUM
var bloqueada_ia : bool = false
var bloqueada_player : bool = false

var funcionarios : Array[Contrato]
var demandas : Array[Contrato]

var efeitosDemandas = {
	"Cafézinho": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		for fun in funcs:
			if fun.area == "TI" or fun.area == "Financeiro":
				increm += 5
		return [increm, prod]
		,
	"Bombom da Meta": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		for fun in funcs:
			if fun.area == "RH" or fun.area == "Marketing":
				increm += 5
		return [increm, prod]
		,
	"Palestra Irada": 
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
	"Time Novo": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		if combo in [2, 3, 4, 8]:
			prod += 2
		return [increm, prod]
		,
	"Redução de Prazos": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		if combo in [3, 4, 8]:
			prod += 3
		return [increm, prod]
		,
	"Política Diversa": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		if combo == 8:
			prod += 4
		return [increm, prod]
		,
	"Confraternização": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int): 
		if combo in [6, 10, 12]:
			prod += 4
		return [increm, prod]
		,
	"Ar-condicionado": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		if len(funcs) == 4:
			for fun in funcs:
				increm += 6
		return [increm, prod]
		,
	"Impressora": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.area == "RH":
				prod += 1
		return [increm, prod]
		,
	"Coffee Break": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.cargo == 1:
				increm += 10
		return [increm, prod]
		,
	"Piscina de Bolinhas": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		if len(funcs) == 4:
			for fun in funcs:
				increm += 6
		return [increm, prod]
		,
	"Trabalho Remoto": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.area == "TI" or fun.area == "Marketing":
				prod += 1
		return [increm, prod]
		,
	"Chapéu de Hélice": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.cargo == 1:
				increm += 10
		return [increm, prod]
		,
	"Just-in-Time": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		if len(funcs) == 4:
			for fun in funcs:
				increm += 6
		return [increm, prod]
		,
	"Jurar à Bandeira": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.area == "Financeiro":
				prod += 1
		return [increm, prod]
		,
	"Checadinha Militar": 
		func(funcs : Array[Contrato], increm : int, prod : int, combo : int):
		for fun in funcs:
			if fun.cargo == 1:
				increm += 10
		return [increm, prod]
}

#Pontuação
var combo := 1
var multiplicador := 1
var incrementador := 0
var pontuacao := 0

@onready var root = $"../.."
@onready var mao = $"../../Camera3D/Mao"
@onready var escritorio = $"../.."
@onready var ui = $"../../UI"
@onready var dinheiro: PackedScene = load("res://Scenes/dinheiro.tscn")
@onready var funcionario: PackedScene = load("res://Scenes/funcionario_popup.tscn")
@onready var inimigo := $"../../Inimigo"
@onready var money_sfx := get_parent().get_node("money")
@onready var sala_slct_sfx := $sala_select_sfx
var selecionada : bool = false
@onready var pai_boneco = $Bonequinhos
var bonequinhos : Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Gerenciador.comeca_turno.connect(implementa_pontos)
	inimigo.jogou_carta.connect(popup_carta)
	root.passou_turno.connect(turno_ia)
	bonequinhos = pai_boneco.get_children()
	
func _process(delta: float) -> void:
	if ui.sala == self:
		att_room()
		
	if ui.popup_bg.visible:
		mouse_on = false
	
	for bonequinho in bonequinhos:
		bonequinho.hide()
	for i in range(len(funcionarios)):
		bonequinhos[i].show()
		if dono == Players.IA and Gerenciador.ia_carimbo == Gerenciador.Carimbos.BRINQUEDO:
			bonequinhos[i].modulate = Color(0xc5305fff)
		elif dono == Players.IA and Gerenciador.ia_carimbo == Gerenciador.Carimbos.TRADICIONAL:
			bonequinhos[i].modulate = Color(0xceba73ff)
		elif funcionarios[i].area == "TI":
			bonequinhos[i].modulate = Color(0x4a8acfff)
		elif funcionarios[i].area == "RH":
			bonequinhos[i].modulate = Color(0x702bbfff)
		elif funcionarios[i].area == "Marketing":
			bonequinhos[i].modulate = Color(0xb72435ff)
		elif funcionarios[i].area == "Financeiro":
			bonequinhos[i].modulate = Color(0x55ce81ff)
		elif funcionarios[i].area == "Coringa":
			bonequinhos[i].modulate = Color(0xd59a34ff)
	
	borda.light_negative = bloqueada_player
	if bloqueada_player:
		borda.show()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT] and event.pressed == true and mouse_on: sala_slct_sfx.play()
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouse_on and len(Gerenciador.cartas_selecionadas) <= 0 and Gerenciador.sala_selecionada == null:
			open_room()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouse_on and len(Gerenciador.cartas_selecionadas) <= 0 and Gerenciador.sala_selecionada in vizinhos:
			mover_atacar()
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouse_on and not bloqueada_player and len(Gerenciador.cartas_selecionadas) > 0:
			insert_cartas_player()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and mouse_on and not bloqueada_player and Gerenciador.movimentos_restantes > 0 and dono == Players.JOGADOR:
			if Gerenciador.sala_selecionada == self:
				deselecionar()
				return
			elif Gerenciador.sala_selecionada != null:
				Gerenciador.sala_selecionada.deselecionar()
				
			Gerenciador.sala_selecionada = self
			selecionada = true
			borda2.show()
		elif (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT) and bloqueada_player and event.pressed and mouse_on:
			ui.show_notificacao("Sala bloqueada", Color.YELLOW)

func mover_atacar():
	if Gerenciador.turno != Gerenciador.JOGADOR: return
	var selecionada = Gerenciador.sala_selecionada
	if len(funcionarios) > 0 and selecionada.dono != dono: #ataque
		
		var atacar = await ui.show_aviso(
			"Atacar a Sala %d" % id,
			"Tem certeza que deseja atacar esta sala?"
		)
		
		if not atacar: return
		
		var pont_pl = selecionada.pontuacao
		var pont_ia = pontuacao
		
		var ia_usou_carimbo = false
		
		#50% de chance da ia te carimbar
		if not Gerenciador.ia_usou_ativa and randf() < 0.5:
			if Gerenciador.ia_carimbo == Gerenciador.Carimbos.BRINQUEDO:
				ia_usou_carimbo = true
				Gerenciador.ia_usou_ativa = true
				if randf() <= 0.25:
					ui.show_notificacao("Fuga com CARIMBO. Sala %d com %d pontos vs Sala %d com %d pontos." % [id, pont_ia, selecionada.id, pont_pl], Color.RED)
					carimbo_sfx.play()
					return
				else:
					ui.show_notificacao("Ataque bem-sucedido com CARIMBO! Sala %d com %d pontos vs Sala %d com %d pontos." % [id, pont_ia, selecionada.id, pont_pl], Color.GREEN)
			elif Gerenciador.ia_carimbo == Gerenciador.Carimbos.TRADICIONAL:
				ia_usou_carimbo = true
				Gerenciador.ia_usou_ativa = true
				for fun in funcionarios:
					pont_ia += 10
			if ia_usou_carimbo: carimbo_sfx.play()
		
		Gerenciador.movimentos_restantes = 0
		if pont_ia <= pont_pl: #ia perdeu
			bloqueada_ia = true
			dono = Sala.Players.NENHUM
			demissao_geral()
			if ia_usou_carimbo:
				ui.show_notificacao("Ataque bem-sucedido com CARIMBO! Sala %d com %d pontos vs Sala %d com %d pontos." % [id, pont_ia, selecionada.id, pont_pl], Color.GREEN)
			else:
				ui.show_notificacao("Ataque bem-sucedido! Sala %d com %d pontos vs Sala %d com %d pontos." % [id, pont_ia, selecionada.id, pont_pl], Color.GREEN)
		else:
			if ia_usou_carimbo:
				ui.show_notificacao("Ataque falhou com CARIMBO... Sala %d com %d pontos vs Sala %d com %d pontos." % [id, pont_ia, selecionada.id, pont_pl], Color.RED)
			else:
				ui.show_notificacao("Seu ataque foi falhou... Sala %d com %d pontos vs Sala %d com %d pontos." % [id, pont_ia, selecionada.id, pont_pl], Color.RED)
		
	elif len(funcionarios) == 0 and len(selecionada.funcionarios) > 0: #movimento
		
		var mover = await ui.show_aviso(
			"Movimentação para Sala %d" % id,
			"Tem certeza que deseja mover todos os seus funcionários para esta sala?"
		)
		
		if not mover: return
		
		funcionarios = Gerenciador.sala_selecionada.funcionarios.duplicate(true)
		Gerenciador.sala_selecionada.demissao_geral()
		Gerenciador.movimentos_restantes = 0
		Gerenciador.sala_selecionada.pontuacao = Gerenciador.sala_selecionada.calcula_pontos()
		dono = Sala.Players.JOGADOR
		pontuacao = calcula_pontos()
		
	Gerenciador.sala_selecionada.deselecionar()

func deselecionar():
	Gerenciador.sala_selecionada = null
	selecionada = false
	borda2.hide()

func turno_ia():
	bloqueada_player = false
	borda.hide()

func demissao_geral():
	funcionarios.clear()
	dono = Players.NENHUM

func open_room():
	ui.show_sala(self)
	
func att_room():
	var func_imagens = []
	var utils = []
	for fun in funcionarios:
		func_imagens.append(fun.sprite)
	
	for util in demandas:
		utils.append("- " + util.nome + ": " + util.desc)
		
	var donoSala
	match dono:
		Players.JOGADOR:
			donoSala = "Sua sala"
		Players.IA:
			donoSala = "Sala inimiga"
		Players.NENHUM:
			donoSala = "Sala sem dono"
		
	ui.set_cartas(func_imagens)
	ui.set_utilitarios(utils)
	ui.set_combo_prod_dono(Gerenciador.combos[combo][0], Gerenciador.combos[combo][1],\
		pontuacao, donoSala)

func insert_cartas_player():
	if Gerenciador.turno != Gerenciador.JOGADOR: return
	
	if dono == Players.IA: 
		ui.show_notificacao("BURRO! Essa sala não é sua!", Color.YELLOW)
		return
		
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
			
	if len(Gerenciador.salas_jogadas) >= 2 and id not in Gerenciador.salas_jogadas.keys() \
		and quantFunc > 0:
			ui.show_notificacao("Limite de duas salas por turno atingido", Color.YELLOW)
			return
	
	if quantFunc + len(funcionarios) > 4: 
		ui.show_notificacao("Limite de funcionários por sala atingido", Color.YELLOW)
		return
	if quantDemanda + len(demandas) > 3: 
		ui.show_notificacao("Limite de demandas por sala atingido", Color.YELLOW)
		return
	if quantDemanda > 0 and len(funcionarios) <= 0: 
		ui.show_notificacao("Sala sem dono", Color.YELLOW)
		return
	if custo > Gerenciador.jogador_dinheiro: 
		ui.show_notificacao("Dinheiro insuficiente", Color.YELLOW)
		return
	
	if quantFunc > 0:
		Gerenciador.salas_jogadas[id] = self
		
	Gerenciador.jogador_dinheiro -= custo
	
	for carta in Gerenciador.cartas_selecionadas:
		var contrato = carta.contrato
		if contrato.tipo == Contrato.Tipos.FUNCIONARIO:
			funcionarios.append(contrato)
			dono = Players.JOGADOR
		else:
			demandas.append(contrato)
	
	mao.descarta(false)
	pontuacao = calcula_pontos()

func calcula_pontos() -> int:
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
	
	return multiplicador * incrementador

func implementa_pontos():
	Gerenciador.movimentos_restantes = 1
	Gerenciador.salas_jogadas.clear()
	bloqueada_ia = false
	pontuacao = calcula_pontos()
	match dono:
		Players.JOGADOR:
			Gerenciador.jogador_dinheiro += int(pontuacao / 2)
			var din = dinheiro.instantiate()
			add_child(din)
			money_sfx.play()
			din.label.text = "R$"+str(int(pontuacao/2))
			din.position = Vector3.ZERO
			din.sumir()
		Players.IA:
			Gerenciador.IA_dinheiro += int(pontuacao / 2)

func popup_carta(tipo: Contrato.Tipos, sala_id: int) -> void:
	if sala_id != id: return
	if tipo == Contrato.Tipos.FUNCIONARIO:
		var fn = funcionario.instantiate()
		add_child(fn)
		fn.label.text = "+1 funcionario"
		fn.position = Vector3.ZERO
		fn.sumir()
		return
	var fn = funcionario.instantiate()
	add_child(fn)
	fn.label.text = "+1 demanda"
	fn.position = Vector3.ZERO
	fn.sumir()

func _on_area_3d_mouse_entered() -> void:
	borda.show()
	mouse_on = true

func _on_area_3d_mouse_exited() -> void:
	borda.hide()
	mouse_on = false
