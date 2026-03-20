extends Control

const wait_time: float = 4.5

@onready var silvio_icon := $Portrait
@onready var dialogbox_silvio := $Portrait/DialogBox
@onready var silvio_text := $Portrait/DialogBox/Dialog
@onready var digit_sfx := $"../Dialog/digitacao"
@onready var dialog_ingame := $"../Dialog"

#highlights
@onready var mask := $BackBufferCopy/Mask
@onready var cartas := $"../Cartas_pos"
@onready var salas := $"../Salas_pos"
@onready var rodadas := $"../RodadaContador"
@onready var carimbos := $"../Carimbo_pos"
@onready var descarte := $"../PlayerSide/DescarteBtn"
@onready var prancheta := $"../EnemySide/Prancheta"
@onready var combos := $"../PlayerSide/Baralho"
@onready var turno := $"../PlayerSide/PularBtn"
@onready var info := $"../EnemySide/InfoBtn"

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
	var tween = create_tween()
	tween.set_parallel(true)
	
	if cenaAtual == 0 and dialogoAtual == 0:
		mask.set_position(salas.position)
		mask.size = salas.size
	elif cenaAtual == 0 and dialogoAtual == 3:
		tween.tween_property(mask, "global_position", cartas.global_position, 0.75)
		tween.tween_property(mask, "size", cartas.size, 0.75)
	elif cenaAtual == 0 and dialogoAtual == 4:
		tween.tween_property(mask, "global_position", descarte.global_position, 0.75)
		tween.tween_property(mask, "size", descarte.size, 0.75)
	elif cenaAtual == 0 and dialogoAtual == 5:
		tween.tween_property(mask, "global_position", rodadas.global_position, 0.75)
		tween.tween_property(mask, "size", rodadas.size, 0.75)
	elif cenaAtual == 0 and dialogoAtual == 6:
		tween.tween_property(mask, "global_position", turno.global_position, 0.75)
		tween.tween_property(mask, "size", turno.size, 0.75)
	elif cenaAtual == 1 and dialogoAtual == 0:
		tween.tween_property(mask, "global_position", salas.global_position, 0.75)
		tween.tween_property(mask, "size", salas.size, 0.75)
	elif cenaAtual == 1 and dialogoAtual == 5:
		tween.tween_property(mask, "global_position", carimbos.global_position, 0.75)
		tween.tween_property(mask, "size", carimbos.size, 0.75)
	elif cenaAtual == 2 and dialogoAtual == 0:
		tween.tween_property(mask, "global_position", prancheta.global_position, 0.75)
		tween.tween_property(mask, "size", prancheta.size, 0.75)
	elif cenaAtual == 2 and dialogoAtual == 1:
		tween.tween_property(mask, "global_position", combos.global_position, 0.75)
		tween.tween_property(mask, "size", combos.size, 0.75)
	elif cenaAtual == 2 and dialogoAtual == 2:
		tween.tween_property(mask, "global_position", info.global_position, 0.75)
		tween.tween_property(mask, "size", info.size, 0.75)

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
