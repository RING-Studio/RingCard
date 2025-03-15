extends CardState


func enter():
	print_debug(state," entered")


func exit():
	pass
	

func on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		card.global_position = card.get_global_mouse_position() - card.pivot_offset
	if event is InputEventMouse:
		if event.is_action_pressed("mouse_right"):
			transition_requested.emit(self, StateName.IDLE)
		elif event.is_action_released("mouse_left"):
			transition_requested.emit(self, StateName.RELEASED)


func on_mouse_entered() -> void:
	pass # Replace with function body.


func on_mouse_exited() -> void:
	pass # Replace with function body.
