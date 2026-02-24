extends Node

var pilha_carta: Array[Carta]

func _ready():
	for cargo in Carta.Cargos:
		for area in Carta.Areas:
			var temp_carta = Carta.new()
			temp_carta.area = area
			temp_carta.cargo = cargo
			pilha_carta.append(temp_carta)
	var coringa = Carta.new()
	coringa.coringa = true
	pilha_carta.append(coringa)

	pilha_carta.shuffle()
