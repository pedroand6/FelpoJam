extends Camera3D

@export var MOUSE_SENSITIVITY: float = 5.0/1000.0
@onready var parent

func _ready():
	parent = get_parent()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_x(event.relative.y * -MOUSE_SENSITIVITY)
		rotation.x = clamp(rotation.x, deg_to_rad(-40), deg_to_rad(40))
		parent.rotate_y(event.relative.x * -MOUSE_SENSITIVITY)
		parent.rotation.y = clamp(parent.rotation.y, deg_to_rad(-60), deg_to_rad(60))

func _process(_delta: float) -> void:
	if rotation.z != 0.0:
		rotation.z = 0.0
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
