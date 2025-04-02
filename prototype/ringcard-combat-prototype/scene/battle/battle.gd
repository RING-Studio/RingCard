extends Node2D
class_name Battle

@onready var card_drop_area: Area2D = $CardDropArea
@onready var card_drop_area_color_rect: ColorRect = $CardDropArea/ColorRect
@onready var site_select_hud: SiteSelectHUD = $SiteSelectHUD

@onready var hand: Control = %Hand


var current_card: Card

func _ready() -> void:
	Events.card_start_targeting.connect(_on_card_start_targeting)
	Events.card_play_failed.connect(_on_card_play_failed)
	Events.card_end_playing.connect(_on_card_end_playing)
	

func _on_card_start_targeting(card: Card):
	current_card = card
	
func _on_card_play_failed(card: Card):
	current_card = null

func _on_card_end_playing(card: Card):
	current_card = null
