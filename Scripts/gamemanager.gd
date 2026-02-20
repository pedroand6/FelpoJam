extends Node

var card_stack: Array[Card]

func _ready():
	for rank in Card.Cargos:
		for area in Card.Areas:
			var temp_card = Card.new()
			temp_card.Area = area
			temp_card.Cargo = rank
			card_stack.append(temp_card)
	print(len(card_stack))
	pass
