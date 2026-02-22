extends Node2D

@onready var dialogos = read_json("res://Dialogues/Cena1.json")
@onready var caixaDialogo = $CanvasLayer/BottomArea/DialogueBox

var dialogoAtual = 0
var cenaAtual = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	atualiza_cena()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("PassaDialogo"):
		passa_dialogo()

func read_json(fileName: String):
	var file = FileAccess.open(fileName, FileAccess.READ)
	var json_object = JSON.new()
	var _parse_err = json_object.parse(file.get_as_text())
	return json_object.get_data()
	

func passa_dialogo():
	dialogoAtual += 1
	if dialogoAtual >= len(dialogos["Cena1"][cenaAtual]):
		dialogoAtual = 0
		cenaAtual += 1
		
	atualiza_cena()

func atualiza_cena():
	caixaDialogo.text = dialogos["Cena1"][cenaAtual][dialogoAtual]["texto"]
