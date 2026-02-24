extends Node3D

const VELOCIDADE: float = 500.0

func _input(event: InputEvent) -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var pos_cursor = get_viewport().get_mouse_position()
	var mov := Input.get_vector("controle_esquerda", "controle_direita", "controle_cima", "controle_baixo")

	Input.warp_mouse(round(pos_cursor + mov * VELOCIDADE * delta))
	
	if Input.is_action_just_pressed("selecionar"):
		var click := InputEventMouseButton.new()
		click.pressed = true
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = pos_cursor
		get_viewport().push_input(click)
	if Input.is_action_just_released("selecionar"):
		var click := InputEventMouseButton.new()
		click.pressed = false
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = pos_cursor
		get_viewport().push_input(click)
