extends CardState


func enter():
	print_debug(state," entered")
	
	if !card.can_play():
		return
	
	if card.target_type == CardData.TargetType.NONE:
		transition_requested.emit(self, StateName.PLAYING)
		return
		
	Events.card_start_targeting.emit(card)
	
	card.get_targets()
	if card.targets.size() > 0:
		transition_requested.emit(self, StateName.PLAYING)
	else:
		print("Failed to play. No target")
		transition_requested.emit(self, StateName.IDLE)
	

func exit():
	Events.card_end_targeting.emit(card)
	
	
func on_gui_input(event: InputEvent) -> void:
	pass


func on_mouse_entered() -> void:
	pass # Replace with function body.


func on_mouse_exited() -> void:
	pass # Replace with function body.
