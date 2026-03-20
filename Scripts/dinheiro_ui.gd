extends RichTextLabel

@onready var effect = custom_effects[0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func run_effect():
	
	effect.run_effect = true
