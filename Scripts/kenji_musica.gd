extends AudioStreamPlayer

@onready var msc2 := "res://Audio/Msc/Segundo vilão part 2.ogg"

func _ready() -> void:
	Gerenciador.round_muda.connect(mudanca)
	process_mode = Node.PROCESS_MODE_ALWAYS

func mudanca() -> void:
	if Gerenciador.round == int(Gerenciador.total_rounds / 2):
		stream = load(msc2)
		play()
