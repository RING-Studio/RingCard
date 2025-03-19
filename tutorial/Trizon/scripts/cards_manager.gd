extends Control

var end_turn_button: Button
var global
var trail_scene = preload("res://scenes/trail.tscn")
@export var banning = false
@onready var showing = $ShowCard
@export var in_battle: bool = false
@export var resolving_arr: Array = []
@export var current_map_location: TextureRect = null
var num_of_wave = 0
var strength = 0.0
var num_of_boss = 0
var map_event
var turn = 0
signal win

var chain_tween: Tween
func show_chain(chain_num):
	if chain_num <= 1: return
	var bg = $Chain
	var tag = $Chain / Label
	tag.text = "CHAIN x " + str(chain_num)
	if chain_tween != null: chain_tween.kill()
	chain_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	chain_tween.tween_property(bg.material, "shader_parameter/offset", 0, 0.3)

	chain_tween.tween_interval(1.0)
	chain_tween.tween_property(bg.material, "shader_parameter/offset", -200, 0.3)



func trial_quadratic_bezier(t: float, mid: Vector2, p0: Vector2, p2: Vector2, trail):
	var q0 = p0.lerp(mid, t)
	var q1 = mid.lerp(p2, t)
	trail.global_position = q0.lerp(q1, t)

func move_trail(from: Vector2, to: Vector2 = Vector2(128, 1080 - 128), time = 1.0):
	var trail = trail_scene.instantiate()
	add_child(trail)
	trail.global_position = from
	trail.emitting = true
	var mid_p = Vector2(to.x, from.y)
	var twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	twn.tween_method(trial_quadratic_bezier.bind(mid_p, from, to, trail), 0.0, 1.0, time)
	await twn.finished
	trail.emitting = false
	await get_tree().create_timer(1.0).timeout
	trail.queue_free()

var ban_twn: Tween
var ban_pos: Vector2 = Vector2(-119, 248)
func ban_turn_bg():
	if ban_twn != null: ban_twn.kill()
	var ban_mask = $BanMask
	ban_mask.visible = true
	ban_twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	ban_twn.tween_property(ban_mask, "global_position", ban_pos, 0.8)
func unban_bg():
	if ban_twn != null: ban_twn.kill()
	var ban_mask = $BanMask
	ban_twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	ban_twn.tween_property(ban_mask, "global_position", Vector2(-119, 1000), 0.8)
	ban_twn.tween_property(ban_mask, "visible", false, 0.0)

func _ready():
	global = Global
	global.current_battle = self

	end_turn_button = get_node("EndTurn")

func split_stack(card):
	if true or card.stack <= 1: return card
	var stack_card_data = card.card_data.duplicate(true)
	var new_stack = Global.instantiate_from_pool()
	new_stack.card_data = stack_card_data
	add_child(new_stack)
	new_stack.change_stack(card.stack - 1)
	card.change_stack(1)
	new_stack.global_position = card.global_position
	new_stack.add_to_group("in_hand")
	return card

func could_die():
	if in_battle and global.LP <= 0:
		if Global.story_mode:
			Global.LP = 1
			return
		in_battle = false
		Dialogic.end_timeline()
		global.LP = global.max_LP
		Global.esc._on_new_game_pressed()

func ban_turn():
	banning = true
	ban_turn_bg()

func draw_from_deck(data = null, accord = "*"):
	if global.deck_to_draw.is_empty(): return
	if data == null:
		var cards: Array
		if accord == "*": cards = Global.deck_to_draw
		else: cards = Global.deck_to_draw.filter(func(d): return d.get("name").match (accord))
		if cards.is_empty(): return
		data = cards[Global.Randi() % cards.size()]
		if !data.has("constant") or "easy_draw" not in data["constant"]:
			data = cards[Global.Randi() % cards.size()]
	global.deck_to_draw.erase(data)
	Global.resolving += 1
	var card = await instantiate_card(data)
	if data.has("deck_to_hand"):
		if !data.has("instantiate"): await get_tree().create_timer(0.31).timeout
		await global.do_effect(null, card, "deck_to_hand")
	else: await get_tree().create_timer(0.1).timeout
	for g in get_tree().get_nodes_in_group("grids"): await global.do_effect(g, g.contain, "any_drawn")
	for i in get_tree().get_nodes_in_group("in_hand"):
		await global.do_effect(null, i, "in_hand_drawn")
	for g in get_tree().get_nodes_in_group("grids"):
		await global.do_effect(g, g.contain, "on_field_drawn")
	Global.resolving -= 1
	return card

func instantiate_card(card_data: Dictionary, spawn_position = Vector2(size.x, size.y)):
	var card: Button = Global.instantiate_from_pool()
	card.visible = true
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	create_tween().tween_property(card, "mouse_filter", Control.MOUSE_FILTER_STOP, 0.4)
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART).tween_property(card, "scale", Vector2(1, 1), 0.4).from(Vector2(0.2, 0.2))
	if card_data["type"] == "mob" and card_data["hp"] <= 0: card_data["hp"] = 1
	card.card_data.merge(card_data.duplicate(true), true)
	card.add_to_group("in_hand")
	add_child(card)
	card.global_position = spawn_position

	back_to_hand()
	if card_data.has("instantiate"): await get_tree().create_timer(0.31).timeout
	await global.do_effect(null, card, "instantiate")
	if card_data.has("enter_hand"): await get_tree().create_timer(0.31).timeout
	await global.do_effect(null, card, "enter_hand")
	if card_data["name"].match ("*fire*"): for g in get_tree().get_nodes_in_group("grids"):
		await global.do_effect(g, g.contain, "any_fire_instantiated")
	return card

func update_order(stack_head = null):
	var inhands = get_tree().get_nodes_in_group("in_hand")
	inhands.sort_custom(func(a, b): return (a.global_position.x < b.global_position.x) or (a.global_position.x == b.global_position.x and a.get_index() < b.get_index()))
	for i in inhands: i.move_to_front()

func back_to_hand(stack_head = null):
	if stack_head != null and !stack_head.is_in_group("in_hand"): stack_head = null
	var max = 8.0
	var cards = get_tree().get_nodes_in_group("in_hand")
	update_order()
	get_tree().call_group("in_hand", "change_stack", 1)
	cards.sort_custom(func(a, b): return a.get_index() < b.get_index())
	var stacks = []
	var reverse_cards = cards.duplicate()
	reverse_cards.reverse()
	var add_to_stack = cards.duplicate()
	for c in cards:
		if stack_head != null and c == stack_head: stacks.append(c)
		elif (stack_head == null or !Global.same_eff(stack_head.card_data, c.card_data)) and (
		!stacks.map(func(s): return s.card_data).any(func(d): return Global.same_eff(c.card_data, d))):
			for rev_c in reverse_cards: if Global.same_eff(rev_c.card_data, c.card_data):
				stacks.append(rev_c)
				break
	for c in stacks: add_to_stack.erase(c)


	for i in range(stacks.size()):
		var relative_index: float = float(i + 0.5) - float(stacks.size()) / 2.0
		var multiplier: float = max / float(stacks.size())
		var goal_position
		var goal_angle
		if stacks.size() >= max:
			goal_position = Vector2(

				global_position.x + size.x / 2 - (stacks[i].size.x - 10) / 2 + (stacks[i].size.x + 10) * (multiplier) * relative_index, 

				global_position.y + size.y / 1.4 + ((relative_index * multiplier) * (1 + 0.05 * max)) ** 2)
			goal_angle = (relative_index * multiplier) / (25.0 + max)
		else:
			goal_position = Vector2(
				global_position.x + size.x / 2 - (stacks[i].size.x - 10) / 2 + (stacks[i].size.x + 10) * relative_index, 
				global_position.y + size.y / 1.4 + (relative_index * (1 + 0.05 * stacks.size())) ** 2)
			goal_angle = relative_index / (25.0 + stacks.size())
		var stack_size = 1
		for c in add_to_stack: if Global.same_eff(c.card_data, stacks[i].card_data):
			c.move_to(goal_position)
			c.change_rotation(goal_angle)
			c.move_to_front()
			stack_size += 1
		stacks[i].move_to(goal_position)
		stacks[i].change_rotation(goal_angle)
		stacks[i].move_to_front()
		stacks[i].change_stack(stack_size)

func _on_end_turn_pressed():
	if global.resolving != 0: return
	end_turn_button.disappear()

	await end_turn()
	await battle_phase()
	await start_turn()
	end_turn_button.appear()

func end_turn():
	for dead_c in global.graveyard.duplicate():
		if dead_c in Global.graveyard:
			await global.do_effect(null, dead_c, "gy_end_phase")
	if Global.has_relic("7CUP"):
		if get_tree().get_nodes_in_group("grids").filter(func(g): return g.contain != null).size() == 7:
			Global.shine_relic("7CUP")
			for i in range(3): await draw_from_deck()
	if Global.has_relic("CYOKO"):
		for g in get_tree().get_nodes_in_group("my_grids"): if g.contain != null:
			Global.shine_relic("CYOKO")
			g.contain.card_data["hp"] += 3
			g.contain.label_tween("hp")
			break
	if Global.has_relic("REDPIG"):
		var non_empty_g = get_tree().get_nodes_in_group("my_grids").filter(func(g): return g.contain != null)
		if non_empty_g.size() == 1:
			Global.shine_relic("REDPIG")
			var tg = non_empty_g[0].contain
			tg.card_data["atk"] += 4
			tg.card_data["hp"] += 4
			tg.label_tween("atk")
			tg.label_tween("hp")
	if Global.has_relic("MAPPOR"):
		Global.shine_relic("MAPPOR")
		var arr = get_tree().get_nodes_in_group("grids").filter(func(g): return g.contain != null)
		if !arr.is_empty(): arr[Global.Randi() % arr.size()].contain.card_data["spell_boost"] += 1

	for grid in get_tree().get_nodes_in_group("grids"): await global.do_effect(grid, grid.contain, "end_phase")

func start_turn(could_win = true):
	turn += 1
	banning = false
	unban_bg()
	for g in get_tree().get_nodes_in_group("grids"): await g.unfreeze()
	if get_tree().get_nodes_in_group("your_grids").filter(func(g): return g.contain != null).is_empty():
		if num_of_wave >= 1:
			num_of_wave -= 1
			Global.pick_chances += 1
			$Turn.refresh(turn, num_of_wave)
			await set_enemy()

			if Global.has_relic("ICECUBE"):
				Global.shine_relic("ICECUBE")
				for i in range(2):
					var arr = get_tree().get_nodes_in_group("your_grids").filter(func(g): return g.contain != null and !g.frozen)
					if !arr.is_empty():
						await arr[Global.Randi() % arr.size()].freeze()

			for g in get_tree().get_nodes_in_group("grids"):
				await Global.do_effect(g, g.contain, "wave_started")
		elif num_of_wave <= 0 and could_win:
			await win_battle()
			return
	else: $Turn.refresh(turn, num_of_wave)
	for i in range(Global.draw_each_turn):
		await draw_from_deck()
	for c_in_hand in get_tree().get_nodes_in_group("in_hand"):
		if c_in_hand.is_in_group("in_hand"): await global.do_effect(null, c_in_hand, "in_hand_draw_phase")

	if Global.has_relic("SYAMIKO") and get_tree().get_nodes_in_group("my_grids").filter(func(g): return g.contain != null).is_empty():
		Global.shine_relic("SYAMIKO")
		await draw_from_deck()
	if Global.has_relic("PPOINT"):
		Global.shine_relic("PPOINT")
		for c in get_tree().get_nodes_in_group("in_hand"): if c.card_data["type"] == "mob":
			c.card_data["atk"] += 1
			c.card_data["hp"] += 1
			c.label_tween("atk")
			c.label_tween("hp")
	if Global.has_relic("RASENN"):
		var g = Global.random_nonempty_grids("my_grids")
		if g:
			Global.shine_relic("RASENN")
			for my_g in get_tree().get_nodes_in_group("my_grids"):
				my_g.contain.card_data["atk"] += 1
				my_g.contain.label_tween("atk")

	for grid in get_tree().get_nodes_in_group("grids"): await global.do_effect(grid, grid.contain, "draw_phase")
	for gy_c in global.graveyard.duplicate():
		if global.graveyard.has(gy_c): await global.do_effect(null, gy_c, "gy_draw_phase")



func win_battle():
	if Global.has_relic("SUNFLOWER") and get_tree().get_nodes_in_group("grids").filter(func(g): return g.contain != null).size() == 3:
		Global.shine_relic("SUNFLOWER")
		Global.pick_chances += 1
	if Global.has_relic("KORO"):
		var allies = get_tree().get_nodes_in_group("my_grids").filter(func(g): return g.contain != null)
		if !allies.is_empty():
			var g = Global.random_nonempty_grids("my_grids")
			if g:
				Global.shine_relic("KORO")
				g.contain.card_data["atk"] += 1
				for data in Global.constant_deck:
					if (data["id"] != -1 and data["id"] == g.contain.card_data["id"]):
						data["atk"] += 1
						break
	turn = 0
	$Turn.refresh(0)
	Global.meta_progress.battle_won += 1
	Global.current_map.map_info.battle_won += 1
	in_battle = false
	global.pick_chances += global.win_reward + num_of_boss * 4
	if map_event != null and (map_event["name"] == "boss" or map_event["name"] == "chimera"):
		await Global.play_plot_at_win_boss()
	if map_event != null and map_event["name"] == "chimera": return
	if num_of_boss >= 1: Global.next_pick_shiny = true
	reset_field()
	global.save()
	win.emit(map_event)
	Global.map_or_pick_card()

func reset_field():
	await get_tree().create_timer(0.21).timeout
	Global.deck_to_draw = []
	Global.graveyard = []
	for c in get_tree().get_nodes_in_group("in_hand"): Global.clear_card_in_hand(c)
	get_tree().call_group("grids", "end_fix")
	get_tree().call_group("grids", "clear_contain")

func sum_cost(enemies: Array):
	var sum = 0
	for enemy in enemies:
		sum += enemy.get("cost")
	return sum

func rand_enemy(of_cost):
	var enemy1_pool = global.enemy_pool.filter(
		func(i): return global.card_prototypes.get(i).get("cost") <= of_cost)
	var enemy1 = global.card_prototypes.get(enemy1_pool[global.Randi() % enemy1_pool.size()]).duplicate(true)
	var leftover_cost = of_cost - enemy1["cost"]
	var enemy2_pool = global.enemy_pool.filter(
		func(i): return global.card_prototypes.get(i).get("cost") == leftover_cost)
	var enemy2 = global.card_prototypes.get(enemy2_pool[global.Randi() % enemy2_pool.size()]).duplicate(true)
	return global.combine([enemy1, enemy2])

func generate_enemy_arr(bound):
	if bound == 0: return []
	var under = bound / 2
	if under < 2: under = 2
	var arr = [0]
	for i in range(4): arr.append(Global.Randi() % bound)
	arr.append(bound)
	arr.sort()
	for i in range(5): arr[i] = arr[i + 1] - arr[i]
	arr.resize(5)
	arr.sort()
	if arr[-1] > under:
		arr[Global.Randi() % 4] += arr[-1] - under
		arr[-1] = under
	arr = arr.filter(func(n): return n != 0)
	arr.sort()
	arr.reverse()
	var ene_arr = []
	for cost in arr: ene_arr.append(Global.rnd_enemy_of_cost(cost))
	return ene_arr

func set_enemy():
	var power_unused = strength


	var bosses = []
	for i in range(num_of_boss):
		bosses.append(global.rnd_boss_under_strength(power_unused))
		power_unused -= bosses[0]["cost"]
		if power_unused <= 0: power_unused = 0

	var bosses_and_enemies = []
	bosses_and_enemies.append_array(bosses)
	bosses_and_enemies.append_array(generate_enemy_arr(power_unused))
	var enemy_cards = []
	for enemy in bosses_and_enemies:
		var grid = Global.random_empty_grids("your_grids")
		if grid == null: break
		var new_enemy = Global.instantiate_from_pool()
		add_child(new_enemy)
		new_enemy.global_position = grid.global_position
		new_enemy.movable = false
		new_enemy.card_data.merge(enemy.duplicate(true), true)
		new_enemy.update()
		new_enemy.material.set_shader_parameter("dissolve_value", 0.0)
		new_enemy.card_icon.material.set_shader_parameter("dissolve_value", 0.0)
		new_enemy.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUINT, 0.85, false)
		await get_tree().create_timer(0.1).timeout
		if enemy["name"] in Global.boss_pool:
			await Global.reveal.reveal(enemy)
		await grid.landed(new_enemy)

		enemy_cards.append(new_enemy)

func set_grid_with(grid, data):
	if grid == null or grid.contain != null: return
	Global.resolving += 1
	var new_creature = Global.instantiate_from_pool()
	new_creature.card_data.merge(data.duplicate(true), true)

	add_child(new_creature)
	new_creature.movable = false
	new_creature.material.set_shader_parameter("dissolve_value", 0.0)
	new_creature.card_icon.material.set_shader_parameter("dissolve_value", 0.0)
	new_creature.global_position = grid.global_position
	new_creature.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUINT, 0.45, false)
	await get_tree().create_timer(0.2).timeout
	await grid.landed(new_creature)

	var at_side = "your_grids"
	if grid.is_in_group("your_grids"): at_side = "my_grids"
	for g in get_tree().get_nodes_in_group(at_side):
		await Global.do_effect(g, g.contain, "enemy_landed", grid)
	Global.resolving -= 1
	return new_creature

func start_battle(num_of_w = 1, intensity = Global.streak, boss_num = 0):
	turn = 0
	intensity = int(intensity)
	Global.meta_progress.boss_killed += boss_num
	num_of_wave = num_of_w
	strength = intensity
	num_of_boss = boss_num
	in_battle = true
	global.deck_to_draw = global.constant_deck.duplicate(true)
	await set_grid_with(Global.random_empty_grids("my_grids"), Global.card_prototypes.get("meat"))
	if Global.has_relic("CHESS"):
		Global.shine_relic("CHESS")
		Global.deck_to_draw.append(Global.card_prototypes.get("attack").duplicate(true))
		Global.deck_to_draw.append(Global.card_prototypes.get("retreat").duplicate(true))
		Global.deck_to_draw.append(Global.card_prototypes.get("Help").duplicate(true))

	for c in Global.deck_to_draw.duplicate():
		if Global.deck_to_draw.has(c):
			await global.do_effect(null, c, "pre_battle")
	for i in range(global.draw_start):
		await draw_from_deck()
	await start_turn()

func battle_phase():
	for grid in get_tree().get_nodes_in_group("my_grids"):
		await global.do_effect(grid, grid.contain, "declare_attack")
		await global.do_effect(grid.grid_in_front, grid.grid_in_front.contain, "declare_attack")

func attack_tween_go(grid: Control, end_position: Vector2):
	var obj = grid.contain
	if obj == null: return
	obj.z_index += 60
	obj.move = create_tween().set_trans(Tween.TRANS_CUBIC)
	obj.move.tween_property(obj, "position", end_position, 0.25)
	await obj.move.finished

func attack_tween_back(grid: Control, end_position: Vector2):
	var obj = grid.contain
	if obj == null: return
	obj.move = create_tween().set_trans(Tween.TRANS_CUBIC)
	obj.move.tween_property(obj, "position", end_position, 0.15)
	await obj.move.finished
	obj.z_index -= 60

func show_card(data):
	showing.mouse_filter = MOUSE_FILTER_STOP
	if data is Button: data = data.card_data
	resolving_arr.append(data)
	showing.card_data = data
	showing.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.36, false)

func stop_showing():
	if resolving_arr.size() == 1:
		var tmp = resolving_arr[0]
		await get_tree().create_timer(0.5).timeout

		resolving_arr.erase(tmp)
		if resolving_arr.size() == 0:
			showing.mouse_filter = MOUSE_FILTER_IGNORE
			showing.play_burn(true, Tween.EASE_OUT, Tween.TRANS_QUART, 0.5, true)
	else:
		resolving_arr.pop_back()
		if !resolving_arr.is_empty(): showing.card_data = resolving_arr[-1]

var rvl_twn: Tween
func play_with_reveal():
	if rvl_twn != null: rvl_twn.kill()
	rvl_twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	rvl_twn.tween_property(self, "rotation_degrees", -5.7, 0.6)
	rvl_twn.parallel().tween_property(self, "scale", Vector2(1.15, 1.15), 0.6)
func stop_with_reveal():
	if rvl_twn != null: rvl_twn.kill()
	rvl_twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	rvl_twn.tween_property(self, "rotation_degrees", 0, 0.6)
	rvl_twn.parallel().tween_property(self, "scale", Vector2(1, 1), 0.6)

func tutorial_0():
	Global.pick_chances = 1
	in_battle = true
	Global.current_map.close()
	await Global.switch_to_scene(Global.current_battle)
	$EndTurn.mouse_filter = MOUSE_FILTER_IGNORE
	set_grid_with($YourField / Grid3, Global.card_prototypes["bear"].duplicate(true))
	Dialogic.start("tutorial_battle_1")
	var code = ["meat", "meat", "bear", "fire_ball", "wolf", "retreat", "Letter", "Letter"]
	for _card in code:
		Global.add_to_constant_deck(Global.card_prototypes[_card].duplicate(true))
	Global.deck_to_draw = Global.constant_deck.duplicate(true)
	await Dialogic.timeline_ended

	await draw_from_deck(Global.deck_to_draw.filter(func(d): return d.name == "meat")[0])
	await draw_from_deck(Global.deck_to_draw.filter(func(d): return d.name == "meat")[0])
	Dialogic.start("tutorial_battle_1_1")
	await Dialogic.timeline_ended
	var to_wait
	for c in get_tree().get_nodes_in_group("in_hand"):
		if c.card_data["cost"] == 0:
			c.glow()
			to_wait = c
	await to_wait.enter_field
	await draw_from_deck(Global.deck_to_draw.filter(func(d): return d.name == "bear")[0])
	Dialogic.start("tutorial_battle_1_2")
	await Dialogic.timeline_ended
	for c in get_tree().get_nodes_in_group("in_hand"):
		if c.card_data["name"] == "bear":
			c.glow()
			to_wait = c
	await to_wait.eat
	Dialogic.start("tutorial_battle_1_3")
	await Dialogic.timeline_ended
	await to_wait.eat
	Dialogic.start("tutorial_battle_1_4")
	await Dialogic.timeline_ended
	while $MyField / Grid3.contain == null:
		await to_wait.enter_field
		var my_bear_grid = get_tree().get_nodes_in_group("my_grids").filter(func(g): return g.contain != null)[0]
		if my_bear_grid.grid_in_front.contain == null:
			my_bear_grid.contain.add_to_group("in_hand")
			my_bear_grid.contain.movable = true
			my_bear_grid.contain.glow()
			my_bear_grid.contain = null
			back_to_hand()
			Dialogic.start("tutorial_battle_1_4_exception")
			await Dialogic.timeline_ended
	Dialogic.start("tutorial_battle_spell")
	await Dialogic.timeline_ended
	var fire_ball = await draw_from_deck(Global.deck_to_draw.filter(func(d): return d.name == "fire_ball")[0])
	Dialogic.start("tutorial_battle_spell_1")
	fire_ball.movable = false
	fire_ball.glow()
	await Global.card_detail_view.quit_check
	Dialogic.start("tutorial_battle_spell_2")
	fire_ball.movable = true
	await fire_ball.spell_used
	Dialogic.start("tutorial_battle_spell_3")
	await Dialogic.timeline_ended
	Dialogic.start("tutorial_battle_1_5")
	await Dialogic.timeline_ended
	$EndTurn.mouse_filter = MOUSE_FILTER_STOP
	await $EndTurn.pressed
	Dialogic.start("tutorial_battle_1_6")

func respawn():
	reset_field()
	for c in get_tree().get_nodes_in_group("in_hand"): Global.clear_card_in_hand(c)
	queue_free()
	var game = load("res://scenes/cards_manager.tscn").instantiate()
	add_sibling(game)
	global.current_battle = game
	game.global_position = Vector2(0.0, -1080.0)

func chimera_fight():
	Music.transin(true)
	map_event = {"name": "chimera", "passed": false, "hidden": false, "eroded": false}
	Dialogic.signal_event.connect(chimera_split)
	Global.current_map.close()
	await Global.switch_to_scene(Global.current_battle)
	Global.play_plot_at_meet_boss()
	strength = 0
	set_grid_with($YourField / Grid3, Global.card_prototypes["chimera"].duplicate(true))
	await start_battle(1, 0, 0)

func chimera_split(argument):
	if argument != "chimera_split": return
	Dialogic.signal_event.connect(Aggres_attack)
	set_grid_with($YourField / Grid, Global.card_prototypes["orge"].duplicate(true))
	set_grid_with($YourField / Grid2, Global.card_prototypes["living_armor"].duplicate(true))
	set_grid_with($YourField / Grid3, Global.card_prototypes["goblin"].duplicate(true))
	set_grid_with($YourField / Grid4, Global.card_prototypes["lion"].duplicate(true))
	set_grid_with($YourField / Grid5, Global.card_prototypes["bear"].duplicate(true))
func Aggres_attack(argument):
	if argument != "Aggres_attack": return
	for g in get_tree().get_nodes_in_group("your_grids"):
		await Global.damage(13, g.contain, g, null, null)
		await Dialogic.signal_event
