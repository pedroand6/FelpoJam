extends Node3D

#TODO: animation on draw
#card spacing
#card sprite by rank + area
#add cards weights

const HAND_SIZE: int = 7
#const HANDS: int = -1
const DESCARTES: int = 1 #descartes por round
const CHOICES: int = 4 #cartas por descarte

var hand_size: int = 0
var cards_hand: Array[Card]

func _ready():
	draw_hand()

func draw_hand():
	while hand_size < HAND_SIZE:
		draw_one()

func draw_one():
	cards_hand.append(Gamemanager.card_stack.pop_back())
	hand_size += 1
	
