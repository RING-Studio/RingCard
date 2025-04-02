extends CardData


func apply_effects(targets: Array[Node]):
	targets.map(func add_pIF(target: Site): target.change_pIF(+1))
	return


func card_play_animation():
	#await Utils.await_time(1)
	return
