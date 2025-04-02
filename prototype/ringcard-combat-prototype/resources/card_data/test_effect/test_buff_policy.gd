extends CardData


func apply_effects(targets: Array[Node]):
	Utils.apply_buff(Utils.get_tree().get_first_node_in_group("opponent"), "void_buff")
	return


func card_play_animation():
	#await Utils.await_time(1)
	return
