extends CardPile
class_name DrawPile

func draw_card(num: int = 1):
	# TODO: 牌数量不够抽
	for i in range(num):
		var card = pop_card()
		if card == null:
			return
			
		if card.get_parent():
			card.reparent(Utils.get_battle().hand)
		else:
			Utils.get_battle().hand.add_child(card)
		
		card.controllable = true
