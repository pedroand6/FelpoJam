extends CanvasLayer

const TRUTH: bool = true

@onready var popup_bg := %Popup
@onready var not_container := $NotContainer
@onready var aviso := %Aviso
@onready var baralho_list := $Popup/Caixa/Frente/Baralho
@onready var config_menu := $Popup/Caixa/Frente/Config
@onready var sala_menu := $Popup/Caixa/Frente/Sala

@onready var donoTxt := $Popup/Caixa/Frente/Sala/Dono
@onready var produtividadeTxt := $Popup/Caixa/Frente/Sala/Produtividade

@export var sala_cartas : Array[TextureRect]
@export var sala_util : Array[RichTextLabel]
@export var sala_combo : Array[RichTextLabel]
var sala : Sala

@onready var round_counter := $RodadaContador
@onready var descarte_counter := $PlayerSide/DescarteBtn/Descartes
@onready var dinheiro_player := $PlayerSide/Dinheiro
@onready var dinheiro_ia := $EnemySide/Dinheiro

@onready var btn_click_sfx = $btn_click
var list_btn_click = ["res://Audio/SFX/CLIQUE BOTÕES 1.wav", "res://Audio/SFX/CLIQUE BOTÕES 2.wav"]

var baralho_show: bool = false
var config_show: bool = false
var sala_show: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_released("fecha_popup"): _on_fechar_button_down()
	round_counter.text = "%02d/%02d" % [Gerenciador.round, Gerenciador.total_rounds]
	descarte_counter.text = "%02d" % Gerenciador.descartes_restantes
	dinheiro_player.text = "R$ " + str(Gerenciador.jogador_dinheiro)
	dinheiro_ia.text = "R$ " + str(Gerenciador.IA_dinheiro)

func _on_baralho_button_down() -> void:
	popup_bg.show()
	baralho_list.show()
	baralho_show = true
	click_sfx()

func _on_config_btn_button_down() -> void:
	popup_bg.show()
	config_menu.show()
	config_show = true
	click_sfx()
	
func show_sala(dono, prod, thisSala) -> void:
	sala = thisSala
	popup_bg.show()
	sala_menu.show()
	donoTxt.text = dono
	if dono == "Sala inimiga":
		produtividadeTxt.text = "Produtividade: ???"
	else:
		produtividadeTxt.text = "Produtividade: " + str(prod)
	sala_show = true
	
func set_cartas(imagens):
	if len(imagens) <= 0: hide_cartas()
	
	for i in range(0, len(imagens)):
		sala_cartas[i].texture = imagens[i]
		sala_cartas[i].show()
		
func set_utilitarios(utils):
	for i in range(0, len(utils)):
		sala_util[i].text = utils[i]

func set_combo(nome, desc):
	sala_combo[0].text = nome
	sala_combo[1].text = desc
	
func hide_cartas():
	for i in range(0, 4):
		sala_cartas[i].hide()
		
func hide_util():
	for i in range(0, 3):
		sala_util[i].text = "-"
	
func _on_resumir_button_down() -> void:
	_on_fechar_button_down()
	click_sfx()

func _on_configuracoes_button_down() -> void:
	pass # Replace with function body.

func _on_sair_button_down() -> void:
	click_sfx()
	Gerenciador.muda_cena(get_parent().name, "res://Scenes/menu.tscn")

func _on_fechar_button_down() -> void:
	click_sfx()
	popup_bg.hide()
	match TRUTH:
		baralho_show:
			baralho_show = false
			baralho_list.hide()
		config_show:
			config_show = false
			config_menu.hide()
		sala_show:
			sala_show = false
			sala_menu.hide()
			hide_cartas()
			hide_util()
		_:
			pass

func _on_demissao_button_down() -> void:
	if sala.dono != Sala.Players.JOGADOR:
		return
		
	#avisar jogador
	var demitir = await show_aviso(
		"Demissão Geral",
		"Deseja mesmo demitir todos os funcionários desta sala?",
	)
	
	if not demitir: return
	
	sala.demissao_geral()
	sala.pontuacao = sala.calcula_pontos()
	sala.open_room()

func show_aviso(title, text):
	aviso.show()
	aviso.title = title
	aviso.text = text
	await aviso.responde_aviso
	return aviso.result

func show_notificacao(text, cor = Color.WHITE):
	var notificacao = load("res://Scenes/notificacao.tscn").instantiate()
	notificacao.set_text(text, cor)
	not_container.add_child(notificacao)

func click_sfx():
	btn_click_sfx.stream = load(list_btn_click[randi() % 2])
	btn_click_sfx.play()
