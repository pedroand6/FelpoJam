extends Node

@export var zona_morta: float = 0.2
@export var dist: float = 5.0
@export var velocidade: float = 100.0

var movimento: Vector2
@onready var cursor := $Cursor
@onready var t_viewport := get_viewport()
@onready var camera := get_viewport().get_camera_3d()
@onready var raio: RayCast3D = RayCast3D.new()
var tamanho_viewport: Vector2
var rid_colisor = null
var ultimo_colisor: CollisionObject3D = null
var controle: bool = false

func _ready() -> void:
	Input.set_custom_mouse_cursor(load("res://Assets/cursor.png"))
	Input.set_custom_mouse_cursor(load("res://Assets/cursor-clicavel.png"), Input.CURSOR_POINTING_HAND)
	get_viewport().size_changed.connect(_viewport_update_size)
	_viewport_update_size()
	cursor.position = get_viewport().get_mouse_position()
	raio.enabled = true
	raio.collide_with_areas = true
	add_child(raio)

func _viewport_update_size() -> void:
	tamanho_viewport = get_viewport().size
	t_viewport = get_viewport()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		movimento = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
		if movimento.length() < zona_morta:
			movimento = Vector2.ZERO
			controle = false
		else:
			controle = true
			_muda_cursor_virtual(true)
			_cursor_move_inject()
	elif not controle and event is InputEventMouseMotion:
		_muda_cursor_virtual(false)
		
	if event is InputEventJoypadButton:
		_muda_cursor_virtual(true)
		if event.button_index == JOY_BUTTON_A:
			_cursor_click_inject(event.pressed)

func _muda_cursor_virtual(mostra : bool):
	if mostra:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		cursor.show()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		cursor.hide()

func _process(delta: float) -> void:
	if movimento != Vector2.ZERO:
		_cursor_move(delta)

func _physics_process(_delta: float) -> void:
		raio.force_raycast_update()
		if not raio.is_colliding():
			if ultimo_colisor and ultimo_colisor.has_signal("mouse_exited"):
				ultimo_colisor.mouse_exited.emit()
			ultimo_colisor = null
			rid_colisor = null
			return
		var rid = raio.get_collider_rid()
		var collider = raio.get_collider()
		if rid != rid_colisor:
			if ultimo_colisor and ultimo_colisor.has_signal("mouse_exited"):
				ultimo_colisor.mouse_exited.emit()
			if collider.has_signal("mouse_entered"): collider.mouse_entered.emit()
		ultimo_colisor = collider
		rid_colisor = rid

func _cursor_move(delta: float) -> void:
	cursor.position += movimento * velocidade * (delta if not controle else delta * 10.0)
	cursor.position.x = clamp(cursor.position.x, 0.0, tamanho_viewport.x)
	cursor.position.y = clamp(cursor.position.y, 0.0, tamanho_viewport.y)
	if controle: _cursor_move_inject()
	
	var origin = camera.project_ray_origin(cursor.position)
	var direction = camera.project_ray_normal(cursor.position)
	raio.global_position = origin
	raio.target_position = direction * dist

func _cursor_click_inject(press: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_mask |= MOUSE_BUTTON_MASK_LEFT
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = press
	event.position = cursor.position
	t_viewport.push_input(event)

func _cursor_move_inject() -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.relative = movimento
	event.screen_relative = movimento
	event.position = cursor.position
	t_viewport.push_input(event)
