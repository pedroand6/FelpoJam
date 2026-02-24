extends Node

@export var zona_morta: float = 0.2
@export var dist: float = 5.0
@export var velocidade: float = 100.0

var movement: Vector2
@onready var cursor := $Cursor
@onready var t_viewport := get_viewport()
@onready var camera := get_viewport().get_camera_3d()
@onready var raycast: RayCast3D = RayCast3D.new()
var viewport_size: Vector2
var ultimo_colisor = null
var last_picked_collider_rid = null
var last_picked_collider: CollisionObject3D = null
var joystick: bool = false

func _ready() -> void:
	get_viewport().size_changed.connect(_viewport_update_size)
	_viewport_update_size()
	cursor.position = get_viewport().get_mouse_position()
	raycast.enabled = true
	raycast.collide_with_areas = true
	add_child(raycast)

func _viewport_update_size() -> void:
	viewport_size = get_viewport().size
	t_viewport = get_viewport()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion:
		alterna_mouse_fake(true)
		movement = Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
		if movement.length() < zona_morta:
			movement = Vector2.ZERO
			joystick = false
		else:
			joystick = true
			_cursor_move_inject()
	elif not joystick and event is InputEventMouseMotion:
		alterna_mouse_fake(false)
		
	if event is InputEventJoypadButton:
		alterna_mouse_fake(true)
		if event.button_index == JOY_BUTTON_A:
			_cursor_click_inject(event.pressed)
		
func alterna_mouse_fake(mostra : bool):
	if mostra:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		cursor.show()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		cursor.hide()

func _process(delta: float) -> void:
	if movement != Vector2.ZERO:
		_cursor_move(delta)

func _physics_process(_delta: float) -> void:
		raycast.force_raycast_update()
		if not raycast.is_colliding():
			if last_picked_collider and last_picked_collider.has_signal("mouse_exited"):
				last_picked_collider.mouse_exited.emit()
			last_picked_collider = null
			last_picked_collider_rid = null
			return
		var rid = raycast.get_collider_rid()
		var collider = raycast.get_collider()
		if rid != last_picked_collider_rid:
			if last_picked_collider and last_picked_collider.has_signal("mouse_exited"):
				last_picked_collider.mouse_exited.emit()
			if collider.has_signal("mouse_entered"): collider.mouse_entered.emit()
		last_picked_collider = collider
		last_picked_collider_rid = rid

func _cursor_move(delta: float) -> void:
	cursor.position += movement * velocidade * (delta if not joystick else delta * 10.0)
	cursor.position.x = clamp(cursor.position.x, 0.0, viewport_size.x)
	cursor.position.y = clamp(cursor.position.y, 0.0, viewport_size.y)
	if joystick: _cursor_move_inject()
	
	var origin = camera.project_ray_origin(cursor.position)
	var direction = camera.project_ray_normal(cursor.position)
	raycast.global_position = origin
	raycast.target_position = direction * dist

func _cursor_click_inject(press: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_mask |= MOUSE_BUTTON_MASK_LEFT
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = press
	event.position = cursor.position
	t_viewport.push_input(event)

func _cursor_move_inject() -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.relative = movement
	event.screen_relative = movement
	event.position = cursor.position
	t_viewport.push_input(event)
