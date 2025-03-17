extends CardState


func enter():
	print_debug(state," entered")
	
	card.put_back()

func exit():
	pass
	
	
func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.is_action_pressed("mouse_left"):
			card.global_position = card.get_global_mouse_position() - card.pivot_offset
			transition_requested.emit(self, StateName.DRAGGING)


func on_mouse_entered() -> void:
	pass # Replace with function body.


func on_mouse_exited() -> void:
	pass # Replace with function body.
