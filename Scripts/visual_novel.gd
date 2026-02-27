extends Node2D


@onready var caixaDialogo = $CanvasLayer/BottomArea
@onready var cenaObj = $CanvasLayer/TopArea/Scene

var nomeCena : String

var dialogos
var cenasPath : String
var cenasImg

var dialogoAtual = 0
var cenaAtual = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nomeCena = "Cena0" + str(Gerenciador.cena)
	dialogos = le_json("res://Dialogues/%s.json" % [nomeCena])
	cenasPath = "res://Dialogues/" + nomeCena + "/"
	cenasImg = le_arquivos(cenasPath)
	atualiza_cena()

func le_json(fileName: String):
	var file = FileAccess.open(fileName, FileAccess.READ)
	var json_object = JSON.new()
	var _parse_err = json_object.parse(file.get_as_text())
	return json_object.get_data()
	
func le_arquivos(path):
	var files = []
	var dir = DirAccess.open(path)
	var returnedFiles = dir.get_files()
	for file in returnedFiles:
		if not file.ends_with(".import"):
			files.append(file)
	print(files)
	return files

func passa_dialogo() -> void:
	if caixaDialogo.textoAnimando:
		caixaDialogo.dialogoObj.visible_ratio = 1.0
		caixaDialogo.textoAnimando = false
		
		caixaDialogo.effect.stopEffect = true
		
		caixaDialogo.continueBtn.visible = true
		return
	
	dialogoAtual += 1
	if dialogoAtual >= len(dialogos[nomeCena][cenaAtual]):
		if cenaAtual + 1 >= len(dialogos[nomeCena]):
			Gerenciador.cena += 1
			if Gerenciador.cena == 2:
				Gerenciador.muda_cena("Visual Novel", "res://Scenes/escritorio.tscn") #FIXME: mudar para tutorial quando tiver
			elif Gerenciador.cena == 4:
				Gerenciador.muda_cena("Visual Novel", "res://Scenes/creditos.tscn")
			else:
				Gerenciador.muda_cena("Visual Novel", "res://Scenes/escritorio.tscn")
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

#Settings code

func _on_config_btn_button_down() -> void:
	%Popup.show()
	%Popup/Caixa/Frente/Config.show()

func _on_resumir_button_down() -> void:
	_on_fechar_button_down()

func _on_fechar_button_down() -> void:
	%Popup.hide()
	%Popup/Caixa/Frente/Config.hide()

func _on_sair_button_down() -> void:
	get_tree().quit()
