class_name Contrato

enum Tipos {
	FUNCIONARIO,
	DEMANDA
}

var tipo : Tipos
var nome : String
var custo : int
var area : String
var cargo : int
var produtividade : int
var id : int
var desc : String
var sprite : Texture2D

func _init(thisTipo : Tipos, thisNome : String, thisCusto : int, thisSprite : Texture2D, thisDesc : String = "", thisArea : String = "", thisCargo : int = -1, 
			thisProdutividade : int = 0, thisId : int = 0) -> void:
	tipo = thisTipo
	nome = thisNome
	custo = thisCusto
	area = thisArea
	cargo = thisCargo
	produtividade = thisProdutividade
	id = thisId
	desc = thisDesc
	sprite = thisSprite
