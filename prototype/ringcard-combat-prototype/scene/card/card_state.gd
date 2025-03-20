extends Node
class_name CardState

enum StateName {IDLE, DRAGGING, RELEASED, TARGETING, PLAYING}

signal transition_requested(from: CardState, to: CardState.StateName)

@export var state: StateName

var card: Card


func enter():
	pass
	
	
func exit():
	pass
	
	
func on_gui_input(event: InputEvent) -> void:
	pass # Replace with function body.


func on_mouse_entered() -> void:
	pass # Replace with function body.


func on_mouse_exited() -> void:
	pass # Replace with function body.
