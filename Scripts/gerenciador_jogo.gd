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
