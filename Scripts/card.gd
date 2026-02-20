class_name Card
extends Node

enum Areas {
	RH,
	TI,
	MARKETING,
	FINANCEIRO
}

enum Cargos {
	JOVEM,
	ESTAGIARIO,
	JUNIOR,
	PLENO,
	SENIOR,
	COORDENADOR,
	GERENTE,
	SUPERINTENDENTE,
	DIRETOR,
	CEO
}

@onready var Ranks: Dictionary = {
	"Jovem" : 1,
	"Estagiário" : 1,
	"Júnior" : 2,
	"Pleno" : 3,
	"Sênior" : 4,
	"Coordenador" : 5,
	"Gerente" : 6,
	"Superintendente" : 7,
	"Diretor" : 8,
	"CEO" : 0,
}

var Area: Areas
var Cargo: Cargos
