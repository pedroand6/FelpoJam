extends Node3D
class_name Carta

var contrato : Contrato

#Secao do funcionario
@onready var funcionarioCard = $Funcionario
@onready var cargoTxt = $Funcionario/Cargo
@onready var areaTxt = $Funcionario/Area
@onready var precoTxt_func = $Funcionario/Preco
@onready var imagem_func = $Funcionario/Imagem

#Secao do utilitario
@onready var utilitarioCard = $Utilitario
@onready var nomeTxt = $Utilitario/Nome
@onready var descTxt = $Utilitario/Desc
@onready var precoTxt_util = $Utilitario/Preco
@onready var imagem_util = $Utilitario/Imagem

var mouse_on: bool = false
var chosen: bool = false
var originalPos: Vector3
var destination: Vector3
var canAnimate: bool

func _ready() -> void:
	if contrato == null: return
	
	if contrato.tipo == Contrato.Tipos.FUNCIONARIO:
		funcionarioCard.show()
		utilitarioCard.hide()
		cargoTxt.text = contrato.nome
		areaTxt.text = contrato.area
		precoTxt_func.text = "R$ %02.2f" % [contrato.custo]
		imagem_func.texture = contrato.sprite
	else:
		funcionarioCard.hide()
		utilitarioCard.show()
		nomeTxt.text = contrato.nome
		descTxt.text = contrato.desc
		precoTxt_util.text = "R$ %02.2f" % [contrato.custo]
		imagem_util.texture = contrato.sprite
		
func set_positions():
	originalPos = position
	destination = position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Gerenciador.turno == Gerenciador.JOGADOR:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouse_on:
			if chosen:
				chosen = false
				var index = Gerenciador.cartas_selecionadas.find(self)
				Gerenciador.cartas_selecionadas.remove_at(index)
			else:
				chosen = true
				Gerenciador.cartas_selecionadas.append(self)
				canAnimate = true
				destination = originalPos + transform.basis.y.normalized() * 0.015 + \
				transform.basis.z.normalized() * 0.01

func _process(delta: float) -> void:
	var distance_to_destination
	var distance_to_move
	if position != destination and canAnimate:
		distance_to_destination = position.distance_to(destination)
		distance_to_move = 50 * delta
		if abs(distance_to_destination) < abs(distance_to_move):
			distance_to_move = distance_to_destination
		position += position.direction_to(destination) * distance_to_move

func _on_area_3d_mouse_entered() -> void:
	mouse_on = true
	scale *= 1.25
	
	if canAnimate == false:
		set_positions()
		canAnimate = true
		
	destination = originalPos + transform.basis.y.normalized() * 0.015 + transform.basis.z.normalized() * 0.01

func _on_area_3d_mouse_exited() -> void:
	mouse_on = false
	scale /= 1.25
	if chosen == false: destination = originalPos
	
