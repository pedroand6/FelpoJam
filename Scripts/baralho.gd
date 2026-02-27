extends Control

@onready var funcs: VBoxContainer = $VBoxContainer/Funcionarios
@onready var utils: VBoxContainer = $VBoxContainer/Util
@onready var coringas: HBoxContainer = $VBoxContainer/Coringas

@onready var funcs_path := "res://Sprites/Cartas/"
@onready var utils_path := "res://Assets/Contratos/Gerais/"
@onready var utils_path2 := "res://Assets/Contratos/Basico/"

class entry_baralho:
	var textrect: TextureRect
	var in_baralho: bool
	var tipo: Contrato.Tipos
	var nome: String
	var area: String
	
	func _init(in_baralho: bool, rect: TextureRect, tipo: Contrato.Tipos, area: String, nome: String):
		textrect = rect
		in_baralho = in_baralho
		tipo = tipo
		nome = nome
		area = area

var lista_entries: Array[entry_baralho] = []

func _ready() -> void:
	Gerenciador.descartada.connect(_modula_cartas)
	var funcionarios_imgs: Array[String] = ler_imagens(funcs_path, true)
	var func_count: int = 0
	var util_imgs: Array[String] = ler_utils(utils_path)
	util_imgs.append_array(ler_utils(utils_path2))
	var util_count: int = 0
	var coringas_imgs: Array[String] = ler_imagens(funcs_path, false)
	var coringas_count: int = 0
	for linha in funcs.get_children():
		for funcionario in linha.get_children():
			var carta_info = funcionarios_imgs[func_count].trim_prefix(funcs_path).split("/") #[0] = AREA, [1] = nome
			var new_entry: entry_baralho = entry_baralho.new(
				true, funcionario, Contrato.Tipos.FUNCIONARIO, carta_info[0], Gerenciador.CARGOS[int(carta_info[1][0])]["nome"]
			)
			lista_entries.append(new_entry)
			funcionario.texture = load(funcionarios_imgs[func_count])
			func_count += 1
#	for linha in utils.get_children():
#		for util in linha.get_children():
#			print(str(len(util_imgs)) + " => " + str(util_imgs))
#			var carta_info = load(util_imgs[util_count])
#			var new_entry: entry_baralho = entry_baralho.new(
#				true, util, Contrato.Tipos.DEMANDA, "", carta_info.nome
#			)
#			lista_entries.append(new_entry)
#			util.texture = carta_info.sprite
#			util_count += 1
	for coringa in coringas.get_children():
		var carta_info = coringas_imgs[coringas_count].trim_prefix(funcs_path)
		var new_entry: entry_baralho = entry_baralho.new(
			true, coringa, Contrato.Tipos.FUNCIONARIO, "Coringa", Gerenciador.CARGOS[int(carta_info[0])]["nome"]
		)
		lista_entries.append(new_entry)
		coringa.texture = load(coringas_imgs[coringas_count])
		coringas_count += 1

func ler_imagens(path: String, pega_diretorios: bool):
	var files: Array[String] = []
	var dir: DirAccess = DirAccess.open(path)
	if pega_diretorios:
		for dirs in dir.get_directories():
			var opened: DirAccess = DirAccess.open(path + dirs)
			for file in opened.get_files():
				if not file.ends_with(".import"):
					files.append(path + dirs + "/" + file)
		return files
	for file in dir.get_files():
		if not file.ends_with(".import"):
			files.append(path + "/" + file)
	return files

func ler_utils(path: String):
	var files: Array[String] = []
	var dir: DirAccess = DirAccess.open(path)
	for file in dir.get_files():
		if not file.ends_with(".import"):
			files.append(path + file)
	return files

func _modula_cartas() -> void:
	for entry: entry_baralho in lista_entries:
		for carta: Carta in Gerenciador.cartas_selecionadas:
			var contr: Contrato = carta.contrato
			if _entry_igual_contrato(entry, contr):
				entry.in_baralho = false
				entry.textrect.modulate = Color(0.2, 0.2, 0.2)

func _entry_igual_contrato(entry: entry_baralho, contr: Contrato) -> bool:
	return entry.area == contr.area and entry.nome == contr.nome and entry.tipo == contr.tipo
