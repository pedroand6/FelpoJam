extends Control

const wait_time: float = 4.5

@onready var silvio_icon := $Portrait
@onready var dialogbox_silvio := $Portrait/DialogBox
@onready var silvio_text := $Portrait/DialogBox/Dialog
@onready var digit_sfx := $"../Dialog/digitacao"
@onready var dialog_ingame := $"../Dialog"
var dialogos

var nomeAtual: String
var nomeCena: String
var dialogoAtual = 0
var cenaAtual = 0
var textoAnimando = false

func _ready() -> void:
	dialogos = le_json("res://Dialogues/tutorial.json")
	nomeCena = "silvio"
	atualiza_cena()
	Gerenciador.comeca_turno.connect(atualiza_cena)
	Gerenciador.turno = 3

func le_json(fileName: String):
	var file = FileAccess.open(fileName, FileAccess.READ)
	var json_object = JSON.new()
	var _parse_err = json_object.parse(file.get_as_text())
	return json_object.get_data()
	
func passa_cena():
	cenaAtual += 1
	Gerenciador.turno = Gerenciador.JOGADOR
	if cenaAtual == 3:
		Gerenciador.comeca_turno.disconnect(atualiza_cena)
		dialogoAtual = 0
		dialog_ingame.start_after_tutorial()
		
		hide()
		return
	else:
		dialogoAtual = 0
		hide()

func passa_dialogo() -> void:
	if textoAnimando:
		silvio_text.visible_ratio = 1.0
		textoAnimando = false
		silvio_text.custom_effects[0].stopEffect = true
		return
	dialogoAtual += 1
	
	if dialogoAtual >= len(dialogos[nomeCena][cenaAtual]):
		passa_cena()
		return
	
	atualiza_cena()

func atualiza_cena():
	show()
	Gerenciador.turno = 3
	mostra_texto(dialogos[nomeCena][cenaAtual][dialogoAtual])

func mostra_texto(dialogoInfo: Dictionary) -> void:
	if dialogoInfo["nome"] == "Silvio, O Presidente":
		silvio_text.text = "[jump_effect]" + dialogoInfo["texto"]
		dialogbox_silvio.show()
		silvio_icon.texture = load("res://Sprites/Icons/%s/%s-retrato-%s.png" % [dialogoInfo["nome"], \
		 	dialogoInfo["nome"].to_lower().split(",", true, 2)[0], dialogoInfo["icone"]])
		anima_texto_silvio()

func anima_texto_silvio():
	silvio_text.custom_effects[0].stopEffect = false
	textoAnimando = true
	silvio_text.visible_characters = 0
	while silvio_text.visible_ratio < 1.0:
		silvio_text.visible_characters += 1
		toca_audio()
		await wait(0.025)
	textoAnimando = false

func toca_audio() -> void:
	if digit_sfx.playing: return
	digit_sfx.play()

func wait(duration):
	await get_tree().create_timer(duration, false, false).timeout

func _on_dialog_box_button_down() -> void:
	passa_dialogo()
