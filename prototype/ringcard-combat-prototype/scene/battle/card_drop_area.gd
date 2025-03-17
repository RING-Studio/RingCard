extends Area2D
class_name CardDropArea

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $ColorRect/AnimationPlayer


func _ready() -> void:
	Events.card_start_dragging.connect(_on_card_start_dragging)
	Events.card_end_dragging.connect(_on_card_end_dragging)
	
	
func _on_card_start_dragging(card: Card):
	animation_player.play("glint")
	
	
func _on_card_end_dragging(card: Card):
	animation_player.play("RESET")
