extends Sprite3D

const TAMANHO_MAO = 7

signal passa_turno
	
@export var salas: Array[Sala]
var ia_mao : Array[Contrato] = []

signal acao_concluida

func _ready():
	pass

func avalia_estado(salas_atuais: Array[Sala], dinheiro: int, mao: Array[Contrato]):
	var turnos_restantes = max(1, Gerenciador.total_rounds - Gerenciador.round + 1)
	var pontos_ia = 0
	var pot_salas = 0
	
	for sala in salas_atuais:
		if sala.dono == sala.Players.IA:
			pontos_ia += sala.calcula_pontos()
			
			pot_salas += 15
			pot_salas += len(sala.funcionarios) * 20
			
			var areas = {}
			var cargos = {}
			for fun in sala.funcionarios:
				if fun.area != "":
					areas[fun.area] = areas.get(fun.area, 0) + 1
				
				cargos[fun.cargo] = cargos.get(fun.cargo, 0) + 1
				
			if not areas.is_empty():
				pot_salas += pow(tipo_mais_repetido(areas), 2) * 3
			if not cargos.is_empty():
				pot_salas += pow(tipo_mais_repetido(cargos), 2) * 5
			   
			pot_salas += len(sala.demandas) * 15
			
	var valor_presente = pontos_ia * 3
	var lucro_projetado = (pontos_ia / 2) * turnos_restantes
	
	var pot_mao = 0
	for contrato in mao:
		if contrato.tipo == Contrato.Tipos.FUNCIONARIO:
			pot_mao += contrato.produtividade * 2
			if contrato.cargo == 0 or contrato.cargo == 9:
				pot_mao += 20 # aqui aumenta bastante pra coringas
			elif contrato.tipo == Contrato.Tipos.DEMANDA:
				pot_mao += 10
			   
	return float(dinheiro) + lucro_projetado + valor_presente + pot_salas + pot_mao


func jogada():
	#compra as cartas da mao
	while len(ia_mao) < TAMANHO_MAO - 1:
		if(len(Gerenciador.ia_baralho) <= 0): break
		compra_carta()
		
	for card in ia_mao:
		print(card.nome)
	
	#colocar as fotos alternando de mais escura pra mais clara pra mostrar o round
	print("jogada da IA")
	
	var salas_jogadas = {}
	var descartes_feitos = 0
	
	descartes_feitos = avalia_descartes(descartes_feitos)
	await joga_cartas(salas_jogadas)
	descartes_feitos = avalia_descartes(descartes_feitos)
	await joga_cartas(salas_jogadas)
	
	await get_tree().create_timer(1.0).timeout
	
	if await avalia_ataque():
		pass
	
	await get_tree().create_timer(0.5).timeout
	passa_turno.emit()
	
signal resposta_defesa_jogador(usou_carimbo: bool)
signal iniciar_animacao_ataque(sala_origem: int, sala_destino: int)

func avalia_ataque() -> bool:
	var atacou = false
	var salas_ia = get_salas_por_dono(Sala.Players.IA)
	var salas_jogador = get_salas_por_dono(Sala.Players.JOGADOR)
	
	for sala_ia in salas_ia:
		for sala_jogador in salas_jogador:
			if sala_jogador in sala_ia.vizinhos:
				var pontos_ia = sala_ia.calcula_pontos()
				var pontos_pl = sala_jogador.calcula_pontos()
				
				#if not player_usou_ativa and player_carimbo == "Básico":
					#f_pl *= 2
					
				# ataque da ia só se tiver 10% a mais de pontos
				if pontos_ia > (pontos_pl * 1.10):
					atacou = true
					
					#emit_signal("iniciar_animacao_ataque", s_ia.id, s_pl.id)
					print("ia atacou sala " + str(sala_ia.id) + "com a sala " + str(sala_jogador.id))
					
					#var usou_ativa = await self.resposta_defesa_jogador
					
					#if usou_ativa:
						#player_usou_ativa = true
						#if player_carimbo == "Brinquedo" and randf() <= 0.25:
							#print("Ataque Anulado pela fuga do Brinquedo!")
							#return true
							
					var pontos_pl_final = sala_jogador.calcula_pontos()
					
					if pontos_ia > pontos_pl_final:
						sala_jogador.demissao_geral()
						sala_jogador.dono = Sala.Players.NENHUM
						sala_jogador.bloqueada_player = true
						
					return true
					
	return atacou
	
func avalia_descartes(descartes_feitos):
	var cartas_para_remover = []
	var salas_ia = get_salas_por_dono(Sala.Players.IA)
	
	var num_demandas = 0
	for carta in ia_mao:
		if carta.tipo == Contrato.Tipos.DEMANDA: 
			num_demandas += 1
	
	for carta in ia_mao:
		if descartes_feitos >= 4:
			break
			
		var sinergia = float(carta.produtividade * 2)
		
		if Gerenciador.IA_dinheiro < carta.custo:
			sinergia -= 20
			
		if num_demandas > 3 or Gerenciador.IA_dinheiro < 30 and carta.tipo == Contrato.Tipos.DEMANDA:
			sinergia -= 3
		
		for sala in salas_ia:
			for fun in sala.funcionarios:
				if carta.area != "" and carta.area == fun.area or carta.area == "Coringa":
					sinergia += 3
				if carta.cargo >= 0 and carta.cargo == fun.cargo:
					sinergia += 8
		
		for outra_carta in ia_mao:
			if outra_carta != carta and outra_carta.tipo == Contrato.Tipos.FUNCIONARIO:
				if outra_carta.area == carta.area or outra_carta.area == "Coringa": sinergia += 2
				if outra_carta.cargo == carta.cargo or outra_carta.cargo == 0: sinergia += 5
				
		sinergia -= carta.custo / 15 - Gerenciador.IA_dinheiro / 15
				
		if sinergia < 15:
			cartas_para_remover.append(carta)
			descartes_feitos += 1
			if carta.tipo == Contrato.Tipos.DEMANDA: num_demandas -= 1
				
	for carta in cartas_para_remover:
		ia_mao.erase(carta)
		compra_carta()
			
	if descartes_feitos > 0:
		print("A IA descartou ", descartes_feitos, " cartas fracas.")
	
	return descartes_feitos

func compra_carta():
	if len(Gerenciador.ia_baralho) > 0:
		var carta_topo = Gerenciador.ia_baralho.pop_back()
		ia_mao.append(carta_topo)
		Gerenciador.ia_baralho_pego.append(carta_topo)

func joga_cartas(salas_jogadas):
	for acao_index in range(4):
		var best_q = avalia_estado(salas, Gerenciador.IA_dinheiro, ia_mao)
		var best_action = null
		
		for carta in ia_mao:
			if Gerenciador.IA_dinheiro >= carta.custo:
				for sala in salas:
					if (sala.dono == Sala.Players.NENHUM or sala.dono == Sala.Players.IA) and not sala.bloqueada_ia:
						if carta.tipo == Contrato.Tipos.FUNCIONARIO and len(sala.funcionarios) < 4:
							if len(salas_jogadas) >= 2 and not sala.id in salas_jogadas:
								continue
							
							sala.funcionarios.append(carta)
							var dono_old = sala.dono
							
							sala.dono = Sala.Players.IA
							
							var mao_sim = ia_mao.duplicate()
							mao_sim.erase(carta)
							var q = avalia_estado(salas, Gerenciador.IA_dinheiro - carta.custo, mao_sim)
							
							sala.funcionarios.pop_back()
							sala.dono = dono_old
							
							if q > best_q + 0.1:
								best_q = q
								best_action = {"carta": carta, "sala": sala}
								
						elif carta.tipo == Contrato.Tipos.DEMANDA and len(sala.demandas) < 3:							
							sala.demandas.append(carta)
							
							var mao_sim = ia_mao.duplicate()
							mao_sim.erase(carta)
							var q = avalia_estado(salas, Gerenciador.IA_dinheiro - carta.custo, mao_sim)
							
							sala.demandas.pop_back()
							
							if q > best_q + 0.1:
								best_q = q
								best_action = {"carta": carta, "sala": sala}
		if best_action != null and not best_action.sala.bloqueada_ia:
			var carta = best_action.carta
			var sala = best_action.sala
			
			if carta.tipo == Contrato.Tipos.FUNCIONARIO:
				sala.funcionarios.append(carta)
				sala.dono = Sala.Players.IA
				Gerenciador.IA_dinheiro -= carta.custo
				ia_mao.erase(carta)
				Gerenciador.ia_baralho.erase(carta)
				Gerenciador.ia_baralho_pego.append(carta)
				salas_jogadas[sala.id] = true
			else:
				sala.demandas.append(carta)
				Gerenciador.IA_dinheiro -= carta.custo
				ia_mao.erase(carta)
				Gerenciador.ia_baralho.erase(carta)
				Gerenciador.ia_baralho_pego.append(carta)
				
			print("IA jogou ", carta.nome, " na sala ", sala.id)
			emit_signal("acao_concluida")
			
			await get_tree().create_timer(0.8).timeout


func tipo_mais_repetido(dict: Dictionary) -> int:
	var m = 0
	for v in dict.values():
		if v > m: m = v
	return m
	
func get_salas_por_dono(dono):
	var result = []
	for sala in salas:
		if sala.dono == dono:
			result.append(sala)
	return result
