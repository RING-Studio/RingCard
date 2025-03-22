extends CanvasLayer

@onready var confirm_button: Button = $ConfirmButton

var current_card: Card
var target_num: int
var random_select: bool = false

func _ready() -> void:
	Events.start_site_selecting.connect(_on_start_site_selecting)


func _on_start_site_selecting(card: Card):
	current_card = card
	select_site(current_card.target_num)


func select_site(target_num: int):
	pass
