extends CardData


func apply_effects(targets: Array[Node]):
	Utils.get_battle().draw_pile.draw_card(1)
	return


func card_play_animation():
	#await Utils.await_time(1)
	return
