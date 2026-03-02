extends Control

@onready var funcs: VBoxContainer = $Funcs/Funcionarios
@onready var utils: HBoxContainer = $Util
@onready var coringas: HBoxContainer = $Funcs/Coringas

@onready var funcs_path := "res://Sprites/Cartas/ContratosSimplificados/"
@onready var utils_path := "res://Assets/Contratos/Gerais/"
@onready var utils_path2 := "res://Assets/Contratos/Basico/"
@onready var utils_path3 := "res://Assets/Contratos/Brinquedo/"

class entry_baralho:
	extends Object
	
	var textrect: TextureRect
	var in_baralho: bool
	var tipo: Contrato.Tipos
	var nome: String
	var area: String
	
	func _init(rect: TextureRect, n_tipo: Contrato.Tipos, n_area: String, n_nome: String):
		in_baralho = true
		textrect = rect
		tipo = n_tipo
		nome = n_nome
		area = n_area

var lista_entries: Array[entry_baralho] = []

func _ready() -> void:
	Gerenciador.compra_carta.connect(_modula_cartas)
	append_funcionarios()
	append_utils()
	append_coringas()

func append_funcionarios() -> void:
	var funcionarios_imgs: Array[String] = ler_imagens(funcs_path, true)
	var func_count: int = 0
	for linha in funcs.get_children():
		for funcionario in linha.get_children():
			var carta_info = funcionarios_imgs[func_count].trim_prefix(funcs_path).split("/") #[0] = AREA, [1] = nome
			var new_entry: entry_baralho = entry_baralho.new(
				funcionario, Contrato.Tipos.FUNCIONARIO, carta_info[0], Gerenciador.CARGOS[int(carta_info[1][0])]["nome"]
			)
			lista_entries.append(new_entry)
			funcionario.texture = load(funcionarios_imgs[func_count])
			func_count += 1

func append_utils() -> void:
	var node_list: Array[Node] = utils.get_children()
	var rect_list: Array[Node]
	for node in node_list:
		rect_list.append_array(node.get_children())
	var rect_count: int = 0
	rect_count = append_demanda(Gerenciador.demandas_gerais, rect_list, rect_count)
	if rect_count < 0: return
	if Gerenciador.jogador_carimbo == Gerenciador.Carimbos.BASICO:
		append_demanda(Gerenciador.demandas_basico, rect_list, rect_count)
	elif Gerenciador.jogador_carimbo == Gerenciador.Carimbos.BRINQUEDO:
		print("aaa")
		append_demanda(Gerenciador.demandas_brinquedo, rect_list, rect_count)
	else:
		append_demanda(Gerenciador.demandas_brinquedo, rect_list, rect_count)

func append_coringas() -> void:
	var coringas_imgs: Array[String] = ler_imagens(funcs_path, false)
	var coringas_count: int = 0
	for coringa in coringas.get_children():
		var carta_info = coringas_imgs[coringas_count].trim_prefix(funcs_path)
		var new_entry: entry_baralho = entry_baralho.new(
			coringa, Contrato.Tipos.FUNCIONARIO, "Coringa", Gerenciador.CARGOS[int(carta_info[0])]["nome"]
		)
		lista_entries.append(new_entry)
		coringa.texture = load(coringas_imgs[coringas_count])
		coringas_count += 1

func append_demanda(demandas: Array[Demanda], rects: Array[Node], rect_count: int) -> int:
	for demanda in demandas:
		for i in range(demanda.quantidade):
			if rects[rect_count] is not TextureRect: return -1
			var new_entry = entry_baralho.new(
				rects[rect_count], Contrato.Tipos.DEMANDA, "", demanda.nome
			)
			lista_entries.append(new_entry)
			rects[rect_count].texture = demanda.sprite
			rect_count += 1
	return rect_count

func ler_imagens(path: String, pega_diretorios: bool):
	var files: Array[String] = []
	var dirs: PackedStringArray = ResourceLoader.list_directory(path)
	if pega_diretorios:
		for dir in dirs:
			if not dir.ends_with("/"): continue
			if dir.trim_suffix("/") not in Gerenciador.AREAS: continue
			var opened: PackedStringArray = ResourceLoader.list_directory(path + dir)
			for file in opened:
				if not file.ends_with(".import"):
					files.append(path + dir + file)
		files.sort()
		return files
	for file in dirs:
		if file.ends_with("/"): continue
		if not file.ends_with(".import"):
			files.append(path + file)
	files.sort()
	return files

func _modula_cartas(contrato : Contrato) -> void:
	for entry: entry_baralho in lista_entries:
		if _entry_igual_contrato(entry, contrato) and entry.in_baralho:
			entry.in_baralho = false
			entry.textrect.modulate = Color(0.2, 0.2, 0.2)
			return

func _entry_igual_contrato(entry: entry_baralho, contr: Contrato) -> bool:
	return entry.area == contr.area and entry.nome == contr.nome and entry.tipo == contr.tipo
