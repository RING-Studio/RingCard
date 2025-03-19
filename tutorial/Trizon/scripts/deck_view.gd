extends Control


var global
var card_container
var unique_decks = []
var unique_decks_cards = []
var tween: Tween
@export var visibility: bool = true

func _enter_tree():
	card_container = $ScrollContainer / CardContainer
func get_mana_curve(from):
	var curve = {"0": 0, "1": 0, "2": 0, "3": 0, "other": 0}
	for c_d in from:
		match c_d["cost"]:
			0: curve["0"] += 1
			1: curve["1"] += 1
			2: curve["2"] += 1
			3: curve["3"] += 1
			_: curve["other"] += 1
	return curve

func unglow_all():
	for c in card_container.get_children():
		c.unglow()

func update_deck_slow(from):

	for c in card_container.get_children():
		card_container.remove_child(c)
		c.back_to_pool()
	for card_data in from:

		var card = Global.instantiate_from_pool()
		card.card_data = card_data.duplicate()
		card.movable = false
		card_container.add_child(card)

func update_deck(from, collapse = false):
	var process_count = 0

	for c in card_container.get_children():
		c.change_stack(1)
		card_container.remove_child(c)
		add_child(c)
		c.visible = false
	if not from in unique_decks:

		unique_decks.append(from)
		unique_decks_cards.append([])

	var cards_arr = unique_decks_cards[unique_decks.find(from)]

	for c in cards_arr:
		if not c.card_data in from:
			cards_arr.erase(c)
			c.back_to_pool()

	for card_data in from:

		if collapse:
			var flag = false
			for existing_card in card_container.get_children():
				if Global.same_eff(existing_card.card_data, card_data):
					existing_card.change_stack(existing_card.stack + 1)
					flag = true
					break
			if flag: continue

		process_count += 1
		if process_count >= 10:
			process_count = 0
			await get_tree().process_frame
			if !visibility: break
		var add_arr = cards_arr.filter(func(c): return c.card_data == card_data and c.get_parent() == self)
		if add_arr.is_empty():
			var card = Global.instantiate_from_pool()
			card.card_data = card_data.duplicate()
			card.movable = false
			card_container.add_child(card)
			cards_arr.append(card)
			card.change_stack(1)
			if from == Global.all_cards_pools:
				if card_data["name"] in Global.unlock_order or card_data["name"] in Global.best_unlock_order:
					if card_data["name"] not in Global.basic_pick_pool and card_data["name"] not in Global.best_pick_pool:
						card.modulate = Color(0.4, 0.4, 0.4)
					else: card.modulate = Color.WHITE
		else:
			var add = add_arr[0]
			add.visible = true
			remove_child(add)
			card_container.add_child(add)
			add.change_stack(1)
			if from == Global.all_cards_pools:
				if card_data["name"] in Global.unlock_order or card_data["name"] in Global.best_unlock_order:
					if card_data["name"] not in Global.basic_pick_pool and card_data["name"] not in Global.best_pick_pool:
						add.modulate = Color(0.4, 0.4, 0.4)
					else: add.modulate = Color.WHITE

func gradually_load_from(from = Global.deck_to_draw):

	for c in card_container.get_children():
		card_container.remove_child(c)
		add_child(c)
		c.visible = false
	if not from in unique_decks:

		unique_decks.append(from)
		unique_decks_cards.append([])

	var cards_arr = unique_decks_cards[unique_decks.find(from)]

	for c in cards_arr:
		if not c.card_data in from:
			cards_arr.erase(c)
			c.back_to_pool()

	for card_data in from.duplicate():

		var is_old = cards_arr.any(func(c): return c.card_data == card_data and c.get_parent() == self)
		if !is_old:
			var card = Global.instantiate_from_pool()
			card.card_data = card_data.duplicate()
			card.movable = false
			add_child(card)
			cards_arr.append(card)
			card.global_position = Vector2(-300.0, -300.0)

	print("done")

func fake_hide():
	visibility = false
	if tween != null: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Mask.material, "shader_parameter/edge", 1.0, 0.3)
	tween.parallel().tween_property($ScrollContainer, "visible", false, 0.26)
	tween.tween_property($Mask, "visible", false, 0.0)
	tween.tween_property($BlurBg, "visible", false, 0.0)
	tween.parallel().tween_property($BlurBg.material, "shader_parameter/alpha", 0.0, 0.3)
	mouse_filter = MOUSE_FILTER_IGNORE

func set_hide():
	visibility = false
	$Mask.material.set_shader_parameter("edge", 1.0)
	$ScrollContainer.visible = false
	$Mask.visible = false
	$BlurBg.visible = false
	$BlurBg.material.set_shader_parameter("alpha", 0.0)
	mouse_filter = MOUSE_FILTER_IGNORE

func fake_appear():
	visibility = true
	if tween != null: tween.kill()
	$BlurBg.visible = true
	$Mask.visible = true
	$ScrollContainer.visible = true
	mouse_filter = MOUSE_FILTER_STOP
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property($Mask.material, "shader_parameter/edge", 0.05, 0.25)
	tween.parallel().tween_property($BlurBg.material, "shader_parameter/alpha", 1.0, 0.25)
