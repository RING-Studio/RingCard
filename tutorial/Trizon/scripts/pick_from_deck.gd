extends Control
var global
var deck_view
var selected_cards = []
@export var mode = "fusion"
@export var event_text: Control
@export var max_selecting = 2
@onready var sample = $Card
var tribute_index = 0
var is_eroded
func sample_burn(time: float = 0.4):
	sample.mouse_filter = MOUSE_FILTER_IGNORE
	sample.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUINT, time, true)
	sample.unglow()
func sample_appear(time: float = 0.4):
	sample.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, time, false)
	sample.mouse_filter = MOUSE_FILTER_STOP
	sample.glow()
	sample.update()

func _ready():
	global = get_node("/root/Global")
	global.pick_from_deck = self
	deck_view = get_node("DeckView")
	event_text = get_node("Event/TextEdit")

func refresh(change_to, eroded = false, arg = 0):
	selected_cards = []
	is_eroded = eroded
	mode = change_to
	$Confirm.text = tr("CONFIRM")
	$Skip.text = tr("SKIP")
	sample_burn(0)
	match change_to:
		"fusion":
			max_selecting = 2
		"swap":
			max_selecting = 1
		"tribute":
			max_selecting = 1
			tribute_index = arg
		"loot_card":
			max_selecting = 1
		"choose_loot_card":
			max_selecting = 1
		"collection":
			max_selecting = 999
			Global.load_loot_card()
			$Confirm.text = tr("DELETE")
			$Skip.text = tr("BACKTOTITLE")
	event_text.text = global.ui.get(mode)
	if mode == "tribute": event_text.text += "\n" + tr("TRIBUTE" + str(tribute_index))
	var deck = deck_view.card_container
	if mode == "choose_loot_card" or mode == "collection": await deck_view.update_deck(global.loot_cards)
	else: await deck_view.update_deck(global.constant_deck)
	var children: Array = deck.get_children()
	for card in children:
		if !card.clicked.is_connected(move_to_selected): card.clicked.connect(move_to_selected)
	deck_view.unglow_all()

func update_sample():
	var selected_cards_datas = []
	for c in selected_cards: selected_cards_datas.append(c.card_data)
	sample_appear()
	if selected_cards.is_empty(): sample_burn()

	elif mode == "choose_loot_card" or mode == "loot_card" or mode == "tribute": sample.card_data = selected_cards_datas[0]
	elif mode == "collection": sample.card_data = selected_cards_datas[-1]
	elif mode == "swap":
		sample.card_data = global.swap(selected_cards_datas[0])
		if is_eroded: sample.card_data.cost -= int(sample.card_data.cost / 2)

	elif mode == "fusion":
		if selected_cards_datas.size() == 1: sample.card_data = selected_cards_datas[0]
		else: sample.card_data = Global.combine(selected_cards_datas)

func move_to_selected(card):
	if selected_cards.has(card):
		selected_cards.erase(card)
		card.unglow()
		update_sample()
		return
	if max_selecting == 1 and !selected_cards.has(card) and selected_cards.size() == 1:
		selected_cards[0].unglow()
		selected_cards.clear()

	if (mode == "fusion" and !selected_cards.has(card) and 
		selected_cards.size() < max_selecting):
		selected_cards.append(card)
		card.glow(0.2, 3.0)
		update_sample()

	elif mode == "swap" and selected_cards.is_empty():
		selected_cards.append(card)
		card.glow(0.2, 3.0)
		update_sample()

	elif mode == "tribute" and selected_cards.is_empty():
		selected_cards.append(card)
		card.glow(0.2, 3.0)
		update_sample()

	elif mode == "loot_card" and !selected_cards.has(card) and selected_cards.size() < max_selecting:
		selected_cards.append(card)
		card.glow(0.2, 3.0)
		update_sample()

	elif mode == "choose_loot_card" and !selected_cards.has(card) and selected_cards.size() < max_selecting:
		selected_cards.append(card)
		card.glow(0.2, 3.0)
		update_sample()

	elif mode == "collection" and !selected_cards.has(card):
		selected_cards.append(card)
		card.glow(0.2, 3.0)
		update_sample()

func _on_confirm_pressed():
	if selected_cards.size() != max_selecting and mode != "collection": return
	match mode:
		"fusion": fusion_or_craft()
		"loot_card": loot_card()
		"choose_loot_card": choose_loot_card()
		"collection": collection_delete()
		"swap": swap()
		"tribute": tribute()











func tribute():
	var tributed = selected_cards[0].card_data
	if !is_eroded: Global.constant_deck.erase(tributed)
	match int(tribute_index):
		0: Global.next_pick_fusion = true
		1: Global.pick_chances += 2
		2: Global.add_to_constant_deck(Global.card_prototypes.get("poke_ball").duplicate(true))
		3: for c in Global.constant_deck:
			if c["type"] == "mob":
				c["atk"] += 1
				c["hp"] += 1
		4: Global.pick_chances += tributed["cost"]
		5: Global.gain_LP(tributed["hp"])
		6: Global.relic_progress_plus(1)
	_on_skip_pressed()

func collection_delete():
	for c in selected_cards:
		Global.loot_cards.erase(c.card_data)
	Global.save_loot_card()
	refresh("collection")

func swap():

	for card in selected_cards:
		for data in global.constant_deck:
			if data["id"] == card.card_data["id"]:
				global.constant_deck.erase(data)
				break
	var new_c = global.swap(selected_cards[0].card_data)
	if is_eroded: new_c.cost -= int(new_c.cost / 2)
	global.add_to_constant_deck(new_c)
	_on_skip_pressed()

func choose_loot_card():
	var loot_data = selected_cards[0].card_data
	global.add_to_constant_deck(loot_data)
	_on_skip_pressed()

func loot_card():
	var loot_data = global.constant_deck.filter(func(c): return c["id"] == selected_cards[0].card_data["id"])[0]
	global.loot_cards.append(global.generate_loot_card(loot_data))
	global.save_loot_card()
	_on_skip_pressed()

func fusion_or_craft():
	var selected_cards_datas = []
	var card_to_add
	for c in selected_cards:
		selected_cards_datas.append(c.card_data)
	if selected_cards_datas[0]["type"] != selected_cards_datas[1]["type"]:
		if selected_cards_datas[0]["type"] == "mob": card_to_add = Global.enchant(selected_cards_datas[0], selected_cards_datas[1]["name"])
		else: card_to_add = Global.enchant(selected_cards_datas[1], selected_cards_datas[0]["name"])
	else:
		card_to_add = global.combine(selected_cards_datas)
	for card in selected_cards:
		for data in global.constant_deck:
			if data["id"] == card.card_data["id"]:

				global.constant_deck.erase(data)
				break

	Global.current_map.map_info["fusion_time"] += 1

	await Global.fusion_view.fusion_animation(selected_cards_datas[0], selected_cards_datas[1], card_to_add, 2.0)
	Global.add_to_constant_deck(card_to_add)
	if is_eroded:
		refresh("fusion", false)
	else:
		_on_skip_pressed()

func _on_skip_pressed():
	deck_view.unglow_all()

	if mode == "loot_card":
		Global.abandon_current_run()
		selected_cards = []
		return
	if mode == "collection":
		await Global.load.blur()
		Global.back_to_title()
		return
	selected_cards = []
	update_sample()
	global.save()
	Global.map_or_pick_card()
