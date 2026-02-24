extends Node2D

@export var nomeCena : String = "Cena1"

@onready var dialogos = le_json("res://Dialogues/%s.json" % [nomeCena])
@onready var caixaDialogo = $CanvasLayer/BottomArea

var cenasPath : String = "res://Dialogues/%s/" % [nomeCena]
@onready var cenaObj = $CanvasLayer/TopArea/Scene
@onready var cenasImg = le_cenas(cenasPath)

var dialogoAtual = 0
var cenaAtual = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	atualiza_cena()

func le_json(fileName: String):
	var file = FileAccess.open(fileName, FileAccess.READ)
	var json_object = JSON.new()
	var _parse_err = json_object.parse(file.get_as_text())
	return json_object.get_data()

func le_cenas(path):
	var files = []
	var dir = DirAccess.open(path)
	var returnedFiles = dir.get_files()
	for file in returnedFiles:
		if not file.ends_with(".import"):
			files.append(file)
			
	return files

func passa_dialogo() -> void:
	if caixaDialogo.textoAnimando:
		caixaDialogo.dialogoObj.visible_ratio = 1.0
		caixaDialogo.textoAnimando = false
		caixaDialogo.continueBtn.visible = true
		return
	
	dialogoAtual += 1
	if dialogoAtual >= len(dialogos[nomeCena][cenaAtual]):
		if cenaAtual + 1 >= len(dialogos[nomeCena]):
			return
		
		dialogoAtual = 0
		cenaAtual += 1
	
	atualiza_cena()

func atualiza_cena():
	cenaObj.texture = load(cenasPath + cenasImg[cenaAtual])
	caixaDialogo.mostra_texto(dialogos[nomeCena][cenaAtual][dialogoAtual])
	caixaDialogo.continueBtn.visible = false


func _on_dialogue_btn_button_down() -> void:
	passa_dialogo()
