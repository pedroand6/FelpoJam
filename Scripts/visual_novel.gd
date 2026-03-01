extends Node2D

@onready var caixaDialogo = $CanvasLayer/BottomArea
@onready var cenaObj = $CanvasLayer/TopArea/Scene
@onready var msc = $Musica
@onready var mouse_on_menu = $mouseovermenu

@onready var btn_click_sfx = $btn_click
var list_btn_click = ["res://Audio/SFX/CLIQUE BOTÕES 1.wav", "res://Audio/SFX/CLIQUE BOTÕES 2.wav"]

var nomeCena : String

var dialogos
var cenasPath : String
var cenasImg: Array[String]

var dialogoAtual = 0
var cenaAtual = 0

var msc_list: Array[String] = ["res://Audio/Msc/primeira cutscene.ogg", "res://Audio/Msc/primeira cutscene.ogg", "res://Audio/Msc/silvio final cutscene.ogg"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	msc.stream = load(msc_list[Gerenciador.cena-1])
	msc.play()
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
	
func le_arquivos(path) -> Array[String]:
	var files: Array[String] = []
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
	click_sfx()

func _on_resumir_button_down() -> void:
	_on_fechar_button_down()

func _on_fechar_button_down() -> void:
	%Popup.hide()
	%Popup/Caixa/Frente/Config.hide()
	click_sfx()

func _on_sair_button_down() -> void:
	click_sfx()
	Gerenciador.muda_cena("Visual Novel", "res://Scenes/menu.tscn")

func _on_config_btn_mouse_entered() -> void:
	mouse_on_menu.play()

func click_sfx():
	btn_click_sfx.stream = load(list_btn_click[randi() % 2])
	btn_click_sfx.play()
