extends Control
class_name Aviso

@export var titleTxt : RichTextLabel
@export var textTxt : RichTextLabel

var title = ""
var text = ""
var result := false

signal responde_aviso(resposta : bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	titleTxt.text = title
	textTxt.text = text

func _on_nao_btn_button_down() -> void:
	result = false
	responde_aviso.emit()
	self.hide()

func _on_sim_btn_button_down() -> void:
	result = true
	responde_aviso.emit()
	self.hide()
