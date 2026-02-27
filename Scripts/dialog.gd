extends Node

@onready var lucas_icon := $"../PlayerSide/Portrait"
@onready var dialogbox_lucas := $"../PlayerSide/Portrait/DialogBox"
@onready var lucas_text := $"../PlayerSide/Portrait/DialogBox/Dialog"
@onready var skip_btn := $"../PlayerSide/PularBtn"
@onready var enemy_icon := $"../EnemySide/Portrait"
@onready var dialogbox_enemy := $"../EnemySide/Portrait/DialogBox"
@onready var enemy_text := $"../EnemySide/Portrait/DialogBox/Dialog"
@onready var digit_sfx := $digitacao
var dialogos

var nomeAtual: String
var nomeCena: String
var dialogoAtual = 0
var cenaAtual = 0
var textoAnimando = false

func _ready() -> void:
	Gerenciador.round_muda.connect(dialogo_round)
	if Gerenciador.cena == 2:
		dialogos = le_json("res://Dialogues/ingame01.json")
		nomeCena = "gutenberg"
	else:
		dialogos = le_json("res://Dialogues/ingame02.json")
		nomeCena = "kenji"
	atualiza_cena()

func dialogo_round() -> void:
	if Gerenciador.round in [4, 8]:
		passa_dialogo()

func le_json(fileName: String):
	var file = FileAccess.open(fileName, FileAccess.READ)
	var json_object = JSON.new()
	var _parse_err = json_object.parse(file.get_as_text())
	return json_object.get_data()

func passa_dialogo() -> void:
#	if caixaDialogo.textoAnimando:
#		caixaDialogo.dialogoObj.visible_ratio = 1.0
#		caixaDialogo.textoAnimando = false
#		caixaDialogo.effect.stopEffect = true
#		caixaDialogo.continueBtn.visible = true
#		return
	dialogoAtual += 1
	if dialogoAtual >= len(dialogos[nomeCena][cenaAtual]):
		skip_btn.show()
		dialogbox_enemy.hide()
		dialogbox_lucas.hide()
		if cenaAtual + 1 >= len(dialogos[nomeCena]):
			return
		
		dialogoAtual = 0
		cenaAtual += 1
		return
	
	atualiza_cena()

func atualiza_cena():
	mostra_texto(dialogos[nomeCena][cenaAtual][dialogoAtual])

func mostra_texto(dialogoInfo: Dictionary) -> void:
	if dialogoInfo["nome"] == "Lucas":
		lucas_text.text = "[jump_effect]" + dialogoInfo["texto"]
		skip_btn.hide()
		dialogbox_lucas.show()
		lucas_icon.texture = load("res://Sprites/Icons/%s/%s-retrato-%s.png" % [dialogoInfo["nome"], \
		 	dialogoInfo["nome"].to_lower().split(",", true, 2)[0], dialogoInfo["icone"]])
		anima_texto_lucas()
	else:
		enemy_text.text = "[jump_effect]" + dialogoInfo["texto"]
		dialogbox_enemy.show()
		enemy_icon.texture = load("res://Sprites/Icons/%s/%s-retrato-%s.png" % [dialogoInfo["nome"], \
		 	dialogoInfo["nome"].to_lower().split(",", true, 2)[0], dialogoInfo["icone"]])
		anima_texto_enemy()
	await wait(3.5)
	passa_dialogo()

func anima_texto_lucas():
	lucas_text.custom_effects[0].stopEffect = false
	textoAnimando = true
	lucas_text.visible_characters = 0
	while lucas_text.visible_ratio < 1.0:
		lucas_text.visible_characters += 1
		toca_audio()
		await wait(0.025)
	textoAnimando = false

func anima_texto_enemy():
	enemy_text.custom_effects[0].stopEffect = false
	textoAnimando = true
	enemy_text.visible_characters = 0
	while enemy_text.visible_ratio < 1.0:
		enemy_text.visible_characters += 1
		toca_audio()
		await wait(0.025)
	textoAnimando = false

func toca_audio() -> void:
	if digit_sfx.playing: return
	digit_sfx.play()

func wait(duration):  
	await get_tree().create_timer(duration, false, false).timeout
