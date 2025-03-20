extends CardState


func enter():
	print_debug(state," entered")
	Events.card_start_targeting.emit(card)
	
	var targets = card.get_targets(card.target_type)
	if targets.size() == 0:
		transition_requested.emit(self, StateName.IDLE)
	else:
		transition_requested.emit(self, StateName.PLAYING)
	

func exit():
	Events.card_end_targeting.emit(card)
	
	
func on_gui_input(event: InputEvent) -> void:
	pass


func on_mouse_entered() -> void:
	pass # Replace with function body.


func on_mouse_exited() -> void:
	pass # Replace with function body.
