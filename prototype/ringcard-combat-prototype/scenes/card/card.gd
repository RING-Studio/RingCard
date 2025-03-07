extends Node2D

@export var card_name: String = "未知卡牌"
@export var cost: int = 1
var is_dragging = false

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		is_dragging = true
	elif event is InputEventMouseButton and !event.pressed:
		is_dragging = false

func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position()
