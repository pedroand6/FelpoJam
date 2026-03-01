extends Node3D
class_name Carta

var contrato : Contrato

@onready var imagem = $Imagem
@onready var seleciona_sfx = $selecionasfx
@onready var guarda_sfx = $guardasfx
@onready var mouse_on_carta = $mousehovercarta

var mouse_on: bool = false
var chosen: bool = false
var originalPos: Vector3
var originalRot: Vector3
var destination: Vector3
var canAnimate: bool

var camera

func _ready() -> void:
	if contrato == null: return
	imagem.texture = contrato.sprite
		
func set_positions():
	originalPos = position
	destination = position
	originalRot = rotation

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Gerenciador.turno == Gerenciador.JOGADOR:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mouse_on:
			if chosen:
				chosen = false
				var index = Gerenciador.cartas_selecionadas.find(self)
				Gerenciador.cartas_selecionadas.remove_at(index)
				seleciona_sfx.play()
			else:
				chosen = true
				Gerenciador.cartas_selecionadas.append(self)
				canAnimate = true
				rotation = originalRot
				destination = originalPos + transform.basis.y.normalized() * 0.015
				guarda_sfx.play()

func _process(delta: float) -> void:
	var distance_to_destination
	var distance_to_move
	if position != destination and canAnimate:
		distance_to_destination = position.distance_to(destination)
		distance_to_move = 0.1 * delta
		if abs(distance_to_destination) < abs(distance_to_move):
			distance_to_move = distance_to_destination
		position += position.direction_to(destination) * distance_to_move
		
	if mouse_on:
		camera = get_viewport().get_camera_3d()
		var position2D = get_viewport().get_mouse_position()
		var dropPlane  = Plane(global_position - camera.global_position, global_position)
		var position3D = dropPlane.intersects_ray(
			camera.project_ray_origin(position2D),
			camera.project_ray_normal(position2D))
		
		if position3D == null: return
		var size = Vector2(imagem.texture.get_width(), imagem.texture.get_height()) * \
			imagem.pixel_size * Vector2(scale.x, scale.y) * Vector2(imagem.scale.x, imagem.scale.y)
		print(size)
		var localPos = position3D - global_position
		
		var lerp_val_x : float = remap(localPos.x, 0.0, size.x, 0, 1)
		var lerp_val_y : float = remap(localPos.y, 0.0, size.y, 0, 1)
		var max_angle = PI/12
		
		var rot_x : float = clamp(lerp_angle(-max_angle, max_angle, lerp_val_x), -max_angle, max_angle)
		var rot_y : float = clamp(lerp_angle(-max_angle, max_angle, lerp_val_y), -max_angle, max_angle)
		
		rotation = Vector3(originalRot.x + rot_y, originalRot.y + rot_x, originalRot.z)

func _on_area_3d_mouse_entered() -> void:
	mouse_on = true
	scale *= 1.25
	
	mouse_on_carta.play()
	
	if canAnimate == false:
		set_positions()
		canAnimate = true
	
	destination = originalPos + transform.basis.y.normalized() * 0.015
	imagem.render_priority = 1

func _on_area_3d_mouse_exited() -> void:
	mouse_on = false
	scale /= 1.25
	if chosen == false: destination = originalPos
	imagem.render_priority = 0
	rotation = originalRot
