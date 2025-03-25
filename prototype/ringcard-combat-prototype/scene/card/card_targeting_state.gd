extends CardState


func enter():
	#print_debug(state," entered")
	
	if !card.can_play():
		transition_requested.emit(self, StateName.IDLE)
		return

	Events.card_start_targeting.emit(card)

	if card.target_type == CardData.TargetType.NONE:
		transition_requested.emit(self, StateName.PLAYING)
		return

	await card.get_targets()
	if card.targeting_concealed:
		print("Targeting Concealed")
		card.targeting_concealed = false
		Events.card_play_failed.emit(card)
		transition_requested.emit(self, StateName.IDLE)
	elif card.targets.size() > 0:
		transition_requested.emit(self, StateName.PLAYING)
	else:
		print("Failed to play. No target")
		Events.card_play_failed.emit(card)
		transition_requested.emit(self, StateName.IDLE)
	return


func exit():
	Events.card_end_targeting.emit(card)


func on_gui_input(event: InputEvent) -> void:
	pass


func on_mouse_entered() -> void:
	pass # Replace with function body.


func on_mouse_exited() -> void:
	pass # Replace with function body.
