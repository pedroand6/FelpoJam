extends Node

const JOGADOR = 0
const IA = 1

const AREAS = ['TI', 'Marketing', 'Financeiro', 'RH']

const CARGOS = {
	1: {"nome": "Estagiário", "prod": 1, "custo": 5},
	2: {"nome": "Júnior", "prod": 2, "custo": 10},
	3: {"nome": "Pleno", "prod": 3, "custo": 15},
	4: {"nome": "Sênior", "prod": 4, "custo": 20},
	5: {"nome": "Supervisor", "prod": 5, "custo": 25},
	6: {"nome": "Gerente", "prod": 6, "custo": 30},
	7: {"nome": "Diretor", "prod": 7, "custo": 35},
	8: {"nome": "Vice-presidente", "prod": 8, "custo": 40},
	9: {"nome": "Presidente", "prod": 9, "custo": 60}, 
	0: {"nome": "Filho do dono", "prod": 0, "custo": 60} 
}

var combos := {
	1 : ["Sozinho no Setor", "Sem combinação, multiplicador igual a 1."],
	2 : ["Parceria", "Dois funcionários do mesmo nível, multiplicador igual a 2."],
	3 : ["Trio Parada Dura", "Três funcionários do mesmo nível, multiplicador igual a 3."],
	4 : ["Complô", "Duas duplas de funcionários de mesmo nível, multiplicador igual a 4."],
	6 : ["Reunião do Setor", "Quatro funcionários da mesma área, multiplicador igual a 6."],
	8 : ["Juntos e Misturados", "Quatro funcionários de mesmo nível, multiplicador igual a 8."],
	10 : ["Desigualdade Salarial", "Quatro funcionários em sequência da mesma área, multiplicador igual a 10."],
	12 : ["Happy Hour", "Os quatro funcionários da mesma área de maior nível em sequência, multiplicador igual a 12."]
}

enum Carimbos {
	BASICO,
	BRINQUEDO,
	TRADICIONAL
}

var player_usou_ativa := false
var ia_usou_ativa := false

var demandas_gerais : Array[Demanda]
var demandasPath = "res://Assets/Contratos/Gerais/"

var demandas_basico : Array[Demanda]
var demandasBasPath = "res://Assets/Contratos/Basico/"

var demandas_brinquedo : Array[Demanda]
var demandasBrinqPath = "res://Assets/Contratos/Brinquedo/"

var demandas_tradicional : Array[Demanda]
var demandasTradPath = "res://Assets/Contratos/Tradicional/"

var ia_baralho: Array[Contrato]
var jogador_baralho: Array[Contrato]

var cartas_selecionadas: Array[Carta]
var salas_jogadas : Dictionary[int, Sala] = {}

var ia_baralho_pego: Array[Contrato]
var jogador_baralho_pego: Array[Contrato]

var ia_carimbo : Carimbos
var jogador_carimbo : Carimbos

@export var total_rounds = 8

@export var jogador_dinheiro : int = 150
@export var IA_dinheiro : int = 150

var round : int = 1
var turno : int = JOGADOR
var descartes_restantes : int = 4
var movimentos_restantes : int = 1
var sala_selecionada : Sala = null

var cena: int = 1 #quando acaba uma cena, atualiza ++

signal comeca_turno
signal compra_carta(contrato : Contrato)
signal round_muda
signal vitoria
signal derrota

func _ready():
	carrega_demandas(demandasPath, demandas_gerais)
	carrega_demandas(demandasBasPath, demandas_basico)
	carrega_demandas(demandasBrinqPath, demandas_brinquedo)
	carrega_demandas(demandasTradPath, demandas_tradicional)

func set_carimbos():
	ia_baralho = gera_baralho(ia_carimbo)
	jogador_baralho = gera_baralho(jogador_carimbo)

func carrega_demandas(path, demandas : Array[Demanda]):
	var dir: PackedStringArray = ResourceLoader.list_directory(path)
	for file in dir:
		if file.ends_with("/"): continue
		if not file.ends_with(".import"):
			demandas.append(load(path + file))

func carrega_contratos(path) -> Array[Texture2D]:
	var contratos : Array[Texture2D]
	var dir: PackedStringArray = ResourceLoader.list_directory(path)
	for file in dir:
		if file.ends_with("/"): continue
		if not file.ends_with(".import"):
			contratos.append(load(path + file))
	contratos.sort() #a leitura não é necessariamente em ordem alfabetica
	return contratos

func gera_demandas(demandas, contratos):
	for demanda in demandas:
		for i in range(0, demanda.quantidade):
			var temp_demanda = Contrato.new(Contrato.Tipos.DEMANDA, demanda.nome, demanda.custo, demanda.sprite, demanda.desc)
			contratos.append(temp_demanda)

func gera_baralho(carimbo : Carimbos) -> Array[Contrato]:
	var pilha_carta: Array[Contrato]
	for area in AREAS:
		for cargo in range(1, 9):
			var contratos_paths = carrega_contratos("res://Sprites/Cartas/%s/" % area)
			var temp_contrato = Contrato.new(Contrato.Tipos.FUNCIONARIO, CARGOS[cargo]["nome"], CARGOS[cargo]["custo"],
				contratos_paths[cargo-1], "", area, cargo, CARGOS[cargo]["prod"])
			pilha_carta.append(temp_contrato)
			
	var presidente = Contrato.new(Contrato.Tipos.FUNCIONARIO, CARGOS[9]["nome"], CARGOS[9]["custo"], 
		load("res://Sprites/Cartas/9-presidente.png"), "", "Coringa", 9, CARGOS[9]["prod"])
	var filho_dono = Contrato.new(Contrato.Tipos.FUNCIONARIO, CARGOS[0]["nome"], CARGOS[0]["custo"],
	 	load("res://Sprites/Cartas/0-filhododono.png"), "", "Coringa", 0, CARGOS[0]["prod"])
	
	pilha_carta.append(presidente)
	pilha_carta.append(filho_dono)
	
	gera_demandas(demandas_gerais, pilha_carta)
	match carimbo:
		Carimbos.BASICO:
			gera_demandas(demandas_basico, pilha_carta)
		Carimbos.BRINQUEDO:
			gera_demandas(demandas_brinquedo, pilha_carta)
		Carimbos.TRADICIONAL:
			gera_demandas(demandas_tradicional, pilha_carta)
	
	pilha_carta.shuffle()
	return pilha_carta

func descarte(carta : Carta, pilha_carta : Array[Contrato]):
	pilha_carta.erase(carta.contrato)
	carta.queue_free()

func calcula_combo(funcionarios : Array[Contrato]):
	if len(funcionarios) == 0: return 1
	
	var desigualdade := false #straight
	var reuniao := false #flush
	var tem_coringa := false #filho do dono
	
	var niveis : Array[int] = []
	var niveisIguais : Array[int] = []
	var combinacoes : Array[int] = []
	combinacoes.append(1) # sozinho
	
	for fun in funcionarios:
		if fun.area == "Coringa" and fun.cargo == 0: tem_coringa = true
		
		niveis.append(fun.cargo)
		var area_igual = 0
		var nivel_igual = 0
		for newFunc in funcionarios:
			if newFunc.area == fun.area or newFunc.area == "Coringa":
				area_igual += 1
			if newFunc.cargo == fun.cargo or newFunc.cargo == 0:
				nivel_igual += 1
				
		if area_igual == 4 and len(funcionarios) == 4:
			reuniao = true
			combinacoes.append(6) #reuniao do setor
			break
		
		niveisIguais.append(nivel_igual)
		match nivel_igual:
			2: combinacoes.append(2) #parceria
			3: combinacoes.append(3) #trio parada dura
			4: combinacoes.append(8) #juntos e misturados
	
	if niveisIguais.all(func(e): return e == 2) and len(funcionarios) == 4:
		combinacoes.append(4) #complo
	
	niveis.sort()
	var primeiro = niveis.front()
	
	if len(niveis) > 1:
		for i in range(len(niveis)):
			if niveis[i] == 0 and i > 0:
				niveis[i] = niveis[i-1] + 1
			elif niveis[i] == 0:
				niveis[i] = niveis[i+1] - 1
	
	if niveis == range(primeiro, primeiro + 3, 1):
		desigualdade =  true
		
	if desigualdade and reuniao:
		combinacoes.append(10) #desigualdade salarial
		if primeiro == 6 and not tem_coringa:
			combinacoes.append(12) #happy hour
	
	#print(combinacoes)
	#print(niveisIguais)
	return combinacoes.max()

func desbloqueia_jogar():
	comeca_turno.emit()
	if round == total_rounds:
		round = total_rounds - 1
		finaliza_jogo()
		return
	
	descartes_restantes = 4

func finaliza_jogo():
	print("finalizou")
	Gerenciador.turno = 3
	
	if jogador_dinheiro >= IA_dinheiro:
		vitoria.emit()
	else:
		derrota.emit()
		await get_tree().create_timer(2.0).timeout
		Gerenciador.muda_cena("Escritorio", "res://Scenes/derrota.tscn")

func muda_cena(cena_sai: String, cena_entra: String) -> void:
	var root = get_tree().get_root()
	var cena_saindo = root.get_node(cena_sai)
	root.remove_child(cena_saindo)
	cena_saindo.call_deferred("free")
	var cena_entrando = load(cena_entra)
	var nova_cena = cena_entrando.instantiate()
	root.add_child(nova_cena)

func muda_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(volume))
