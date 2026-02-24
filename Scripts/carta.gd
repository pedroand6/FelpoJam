class_name Carta
extends Node3D

enum Areas {
	RH,
	TI,
	MARKETING,
	FINANCEIRO
}

enum Cargos {
	ESTAGIARIO,
	JUNIOR,
	PLENO,
	SENIOR,
	SUPERVISOR,
	GERENTE,
	DIRETOR,
	VICE_PRESIDENTE,
	PRESIDENTE
}

#@onready var Ranks: Dictionary = {
#	"Jovem" : 1,
#	"Estagiário" : 1,
#	"Júnior" : 2,
#	"Pleno" : 3,
#	"Sênior" : 4,
#	"Coordenador" : 5,
#	"Gerente" : 6,
#	"Superintendente" : 7,
#	"Diretor" : 8,
#	"CEO" : 0,
#}

var area: Areas
var cargo: Cargos
var coringa: bool

@onready var luz_contorno: MeshInstance3D = $'LuzContorno'
@onready var luz_escolha: MeshInstance3D = $'LuzContornoEscolha'
@onready var imagem: Sprite3D = $'Imagem'
var mouse_on: bool = false
const INFO_TIMER: bool = 1.0
var info_timer: float = 1.0
var chosen: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouse_on:
			if chosen:
				chosen = false
				luz_escolha.hide()
			else:
				chosen = true
				luz_escolha.show()

func _process(delta: float) -> void:
	if mouse_on:
		info_timer -= delta
	if info_timer <= 0:
		pass
	else:
		pass

func _on_area_3d_mouse_entered() -> void:
	luz_contorno.show()
	mouse_on = true

func _on_area_3d_mouse_exited() -> void:
	luz_contorno.hide()
	mouse_on = false
	info_timer = INFO_TIMER
