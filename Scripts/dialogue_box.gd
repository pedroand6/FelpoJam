extends Control

@onready var dialogoObj = $DialogueBox
@onready var nomeObj = $Name
@onready var iconObj = $Icon
@onready var continueBtn = $ContinueBtn
@onready var dialogueBtn = $DialogueBtn

@onready var effect = dialogoObj.custom_effects[0]

@onready var audio = $AudioStreamPlayer

var textoAnimando = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogueBtn.grab_focus()

func mostra_texto(dialogoInfo: Dictionary) -> void:
	dialogoObj.text = "[jump_effect]" + dialogoInfo["texto"]
	iconObj.texture = load("res://Sprites/Icons/%s/%s-retrato-%s.png" % [dialogoInfo["nome"], \
		 dialogoInfo["nome"].to_lower().split(",", true, 2)[0], dialogoInfo["icone"]])
	nomeObj.text = dialogoInfo["nome"]
	anima_texto()

func anima_texto():
	effect.stopEffect = false
	textoAnimando = true
	dialogoObj.visible_characters = 0
	while dialogoObj.visible_ratio < 1.0:
		dialogoObj.visible_characters += 1
		toca_audio()
		await wait(0.025)
	textoAnimando = false
	continueBtn.visible = true
	
func toca_audio():
	if audio.playing: return
	audio.play()

func wait(duration):  
	await get_tree().create_timer(duration, false, false).timeout
