extends Node2D
class_name Battle

@onready var card_drop_area: Area2D = $CardDropArea
@onready var card_drop_area_color_rect: ColorRect = $CardDropArea/ColorRect
@onready var site_select_hud: SiteSelectHUD = $SiteSelectHUD

@onready var hand: Control = %Hand
@onready var draw_pile: DrawPile = $DrawPile
@onready var discard_pile: CardPile = $DiscardPile
@onready var draw_pile_button: Button = %DrawPileButton
@onready var discard_pile_button: Button = %DiscardPileButton

var current_card: Card


func _ready() -> void:
	Events.card_start_targeting.connect(_on_card_start_targeting)
	Events.card_play_failed.connect(_on_card_play_failed)
	Events.card_end_playing.connect(_on_card_end_playing)
	
	# debug
	test()

func test():
	var init_card = preload("res://scene/card/card.tscn").instantiate()
	#init_card.card_data = preload("res://resources/card_data/test_effect/test_draw_card.tres")
	#init_card.init()
	draw_pile.add_card(init_card)
	
func is_viewing_draw_pile() -> bool:
	return draw_pile.visible
	
func is_viewing_discard_pile() -> bool:
	return discard_pile.visible
	
func _on_card_start_targeting(card: Card):
	current_card = card
	
func _on_card_play_failed(card: Card):
	current_card = null

func _on_card_end_playing(card: Card):
	current_card = null
	

func _on_draw_pile_button_pressed() -> void:
	if is_viewing_discard_pile():
		return
	draw_pile.show()

func _on_discard_pile_button_pressed() -> void:
	if is_viewing_draw_pile():
		return
	discard_pile.show()
