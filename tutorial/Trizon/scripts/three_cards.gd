extends Control

var choosed: Button
var left_tween: Tween
var right_tween: Tween
var card1
var card2
var card3
var global
var fusion_event = {"name": "!Fusion!", "type": "spell", "atk": 0, "hp": 0, "cost": 0, "constant": ["EVENT"]}
var relic_event = {"name": "!Relic!", "type": "spell", "atk": 0, "hp": 0, "cost": 0, "constant": ["EVENT"]}


func _enter_tree():
	global = get_node("/root/Global")
	card1 = get_node("Card")
	card2 = get_node("Card2")
	card3 = get_node("Card3")
	global.three_cards = self

func new_game():
	reset_choice()
	await get_tree().create_timer(10.0).timeout
	(create_tween().tween_property($Label.material, "shader_parameter/alpha", 0, 3.0)
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART))

func refresh(card: Button, exclude = [], shiny: bool = false):
	card.visible = true
	card.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.4, false)




	if shiny: card.card_data = Global.random_card_data(null, null, exclude, Global.best_pick_pool)
	else: card.card_data = Global.random_card_data(null, null, exclude)

func _on_card_pressed():
	choose_card(card1)
	card2.unglow()
	card3.unglow()
func _on_card_2_pressed():
	choose_card(card2)
	card1.unglow()
	card3.unglow()
func _on_card_3_pressed():
	choose_card(card3)
	card1.unglow()
	card2.unglow()
func choose_card(card: Button):
	if choosed == card:
		card.unglow()
		choosed = null
	else:
		card.glow(0.2, 1.5)
		choosed = card

func operate_buttonbg(bg = $leftbuttonbg, tween = left_tween, offset = -170):
	if tween != null: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(bg.material, "shader_parameter/offset", offset, 0.3)

func _on_confirm_mouse_entered():
	operate_buttonbg($leftbuttonbg, left_tween, 0)
func _on_confirm_mouse_exited():
	operate_buttonbg($leftbuttonbg, left_tween, -170)
	Popups.unpop()
func reset_choice():
	choosed = null
	for card in [card1, card2, card3]: card.unglow()
func _on_confirm_pressed():
	if choosed == null:
		Popups.pop_at($Confirm.global_position + Vector2(400, -100), tr("PICKACARDFIRST"))
		return
	var confirm = $Confirm
	global.pick_chances -= 1
	confirm.visible = false

	var tmp_arr = [card1, card2, card3].filter(func(i): return choosed != i)
	tmp_arr[0].play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.4)
	choosed.unglow()
	tmp_arr[1].play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.4)
	await choosed.play_burn(true, Tween.EASE_IN_OUT, Tween.TRANS_QUAD, 0.6)

	if "constant" not in choosed.card_data or "EVENT" not in choosed.card_data["constant"]:
		global.add_to_constant_deck(choosed.card_data)
		global.save()

		if Global.pick_chances <= 0: Global.current_map.mandatory_pick()
		else: refresh_all()
	elif choosed.card_data["name"] == "!Fusion!":
		Global.pick_from_deck.refresh("fusion")
		await Global.switch_to_scene(Global.pick_from_deck)
	elif choosed.card_data["name"] == "!Relic!":
		Global.relic_progress_plus(1)
		if Global.pick_chances <= 0: Global.current_map.mandatory_pick()
		else: refresh_all()

	confirm.visible = true

func _on_refresh_mouse_entered():
	operate_buttonbg($rightbuttonbg, left_tween, 0)
func _on_refresh_mouse_exited():
	operate_buttonbg($rightbuttonbg, left_tween, 170)

func _on_refresh_pressed():
	if choosed != null:
		choosed.unglow()
		choosed = null
	var refresh = $Refresh
	global.pick_chances -= 1
	refresh.visible = false

	var tmp_arr = [card1, card2, card3]
	tmp_arr[0].play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.4)
	tmp_arr[1].play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.4)
	await tmp_arr[2].play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.4)

	global.save()
	if Global.has_relic("STEINGATE") and Global.Randi() % 100 < 20:
		Global.shine_relic("STEINGATE")
		Global.pick_chances += 1

	if global.pick_chances <= 0:
		global.current_map.mandatory_pick()
	else: refresh_all()
	refresh.visible = true

func refresh_all():
	reset_choice()
	refresh(card1, [])
	refresh(card2, [card1.card_data["name"]])
	refresh(card3, [card1.card_data["name"], card2.card_data["name"]])
	if Global.next_pick_fusion:
		card2.card_data = fusion_event
		Global.next_pick_fusion = false
	if Global.next_pick_shiny:
		refresh(card1, [], true)
		refresh(card2, [card1.card_data["name"]], true)
		refresh(card3, [card1.card_data["name"], card2.card_data["name"]], true)
		Global.next_pick_shiny = false



















func refresh_all_camp_event(eroded: bool = false):
	Global.pick_chances += 1
	reset_choice()
	card1.visible = true;card2.visible = true;card3.visible = true
	for card in [card1, card2, card3]:
		card.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.4, false)
	card1.card_data = Global.card_prototypes.get("bandage").duplicate(true)
	card2.card_data = relic_event
	card3.card_data = Global.card_prototypes.get(Global.consumable_pool[Global.Randi() % Global.consumable_pool.size()]).duplicate(true)
