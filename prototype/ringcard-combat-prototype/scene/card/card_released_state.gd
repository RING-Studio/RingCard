extends CardState


func enter():
	print_debug(state," entered")
	
	if card.can_drop():
		card.play()
	else:
		transition_requested.emit(self, StateName.IDLE)

func exit():
	pass
	
	
func on_gui_input(event: InputEvent) -> void:
	pass


func on_mouse_entered() -> void:
	pass # Replace with function body.


func on_mouse_exited() -> void:
	pass # Replace with function body.
