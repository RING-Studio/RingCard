extends Button
signal clicked(data)
signal enter_field
signal eat
signal spell_used
var hitbox_scene = preload("res://scenes/card_hitbox.tscn")
var damage_pop = preload("res://scenes/damage_pop.tscn")
var enchant_icon = preload("res://scenes/card_enchant.tscn")
var hit_particle_scene = preload("res://scenes/hit_particle.tscn")
@export var dragging: bool = false
@export var movable: bool = true
@export var card_data: Dictionary = {"name": "?", "type": "spell", "atk": 0, "hp": 0, "cost": 0, "id": -1, "spell_boost": 0}
@export var initial_scale: Vector2 = Vector2(1.0, 1.0)
@export var is_dying: bool = false
@export var is_casted: bool = false
var hitbox
@onready var aura_material = $aura.material
var mouse_0: Vector2
var global
@onready var hit_texture = $hit
@onready var card_icon = $CardIcon
var enlarge_tween: Tween
var move: Tween
var aura_tween: Tween
var burn_tween1: Tween
var burn_tween2: Tween
var freeze_tween: Tween
var shake_tween: Tween
var arc_tween: Tween
var data_last_frame
var lang_last_frame
var stack_tween: Tween
var atk_tween: Tween
var hp_tween: Tween
var cost_tween: Tween
var orange_tween: Tween
var enchant_tween: Tween
@export var stack: int = 1

func label_tween(atk_hp_cost: String):
	var twn
	var label
	if atk_hp_cost == "atk":
		twn = atk_tween
		label = $atk
	elif atk_hp_cost == "hp":
		twn = hp_tween
		label = $hp
	elif atk_hp_cost == "cost":
		twn = cost_tween
		label = $cost
	if twn != null: twn.kill()
	twn = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	twn.tween_property(label, "scale", Vector2(1.0, 1.0), 0.0)
	twn.tween_property(label, "scale", Vector2(1.28, 1.28), 0.24)
	twn.set_ease(Tween.EASE_IN)
	twn.tween_property(label, "scale", Vector2(1.0, 1.0), 0.16)

func change_stack(change_to):
	stack = change_to
	if dragging: return
	if stack_tween != null: stack_tween.kill()
	stack_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	if change_to <= 1:
		stack_tween.tween_property($Stack, "modulate", Color.TRANSPARENT, 0.35)
	else:
		$Stack / StackNum.text = "x" + str(change_to)
		stack_tween.tween_property($Stack, "modulate", Color.WHITE, 0.2)

func pop(display = ""):
	var show_damage = damage_pop.instantiate()
	show_damage.text = str(display)
	show_damage.global_position = global_position + size * (0.75 + 0.3 * randf()) / 2 - show_damage.size
	get_parent().add_child(show_damage)
	if int(display) == 0 and str(display) != "-0": show_damage.do(10)
	else: show_damage.do(abs(int(display)))

func hit(damage_amount = 0):
	Music.sound_random_punch()
	var hitParticle = hit_particle_scene.instantiate()
	hitParticle.position += size * scale / 2
	add_child(hitParticle)
	global.shake_strength += 30
	pop("-" + str(damage_amount))
	var hit_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	hit_texture.rotation = randi() % 360 - 180
	hit_tween.tween_property(hit_texture.material, "shader_parameter/alpha", 0.0, 1.2).from(1.0)
	await get_tree().create_timer(0.18).timeout

func _ready():
	var rnd = float(randi() % 314) / 100.0
	material.set_shader_parameter("randomizer", rnd)
	card_icon.material.set_shader_parameter("randomizer", rnd)
	$Frost.material.set_shader_parameter("randomizer", rnd)

	initial_scale = scale
	global = Global

func glow(time = 0.2, intensity = 1.0):
	if aura_tween != null: aura_tween.kill()
	aura_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	aura_tween.tween_property(aura_material, "shader_parameter/alpha", intensity, time)
func unglow():
	if aura_tween != null: aura_tween.kill()
	aura_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	aura_tween.tween_property(aura_material, "shader_parameter/alpha", 0.0, 0.2)

func _process(delta):
	follow_mouse(delta)
	if data_last_frame != card_data: update()
	elif Global.settings.language != lang_last_frame: update_name()
	if card_data.has("constant"):
		for effect in card_data["constant"]:
			if effect.match ("*=*"):
				var val_to_update = effect.split("=")[0]
				var according_to = effect.split("=")[1]
				if according_to == "allies":
					card_data[val_to_update] = get_tree().get_nodes_in_group("my_grids").filter(
						func(g): return g.contain != null).size()
				if effect == "atk=hp": card_data["atk"] = card_data["hp"]

func update_name():
	lang_last_frame = Global.settings.language
	var splited: Array = card_data["name"].split("/", false)
	var names: Array = []
	for item in splited: if not names.has(item): names.append(item)
	if global.card_name.has(card_data["name"]):
		$CardName.text = global.card_name.get(card_data["name"])
	else:
		var conca_name = ""
		for n in names:
			if n.match ("ENCHANTED_*"): conca_name += Global.card_name.get(n.substr(10), "")
			elif global.card_name.has(n): conca_name += global.card_name.get(n)
			if splited.count(n) >= 2: conca_name += "(" + str(splited.count(n)) + ")"
		$CardName.text = conca_name
	update_font()

var lang_font_scale: Dictionary = {
	"zh_CN": [3, 1, 15], 
	"en": [10, 0.5, 10], 
	"ja": [3, 1, 15], 
}
func update():
	lang_last_frame = Global.settings.language
	data_last_frame = card_data.duplicate(true)
	var has_constant = "constant" in card_data
	var gold = has_constant and "gold" in card_data["constant"]
	if has_constant and "rainbow" in card_data["constant"]:
		material.set_shader_parameter("rainbow", true)
		$CardIcon.material.set_shader_parameter("rainbow", true)
	else:
		material.set_shader_parameter("rainbow", false)
		$CardIcon.material.set_shader_parameter("rainbow", false)


	if card_data["type"] == "mob":
		if has_constant and gold:
			$card_bg.texture = load("res://UI/card_bg_creature_gold.png")
		else: $card_bg.texture = load("res://UI/card_bg_creature.png")
	else:
		if has_constant and gold:
			$card_bg.texture = load("res://UI/card_bg_gold.png")
		else: $card_bg.texture = load("res://UI/card_bg.png")
	if gold:
		$Particles.emitting = true
		$Particles.amount = scale.x * 8
		$CardIcon.modulate = Color(1.3, 1.3, 0.9)
	else:
		$Particles.emitting = false
		$CardIcon.modulate = Color.WHITE
	var splited: Array = card_data["name"].split("/", false)
	% Enchanted.amount = min(((splited.size() - 1) * 8 + 8) * scale.x, 1600)
	var main_icon = null
	for child in % Enchant.get_children(): child.queue_free()
	var names: Array = []
	for item in splited: if not names.has(item): names.append(item)
	for icon_name in names:
		if ResourceLoader.exists("res://card_icons/" + icon_name + ".png"):
			if main_icon == null:
				main_icon = load("res://card_icons/" + icon_name + ".png")
			else:
				var new_sub_icon = enchant_icon.instantiate()
				new_sub_icon.texture = load("res://card_icons/" + icon_name + ".png")
				% Enchant.add_child(new_sub_icon)
				break
	if main_icon == null: card_icon.texture = load("res://card_icons/default.png")
	else: card_icon.texture = main_icon
	$atk.text = str(card_data["atk"])
	$hp.text = str(card_data["hp"])
	$cost.text = str(card_data["cost"])
	if has_constant and "EVENT" in card_data["constant"]: $cost.text = ""
	if global.card_name.has(card_data["name"]):
		$CardName.text = global.card_name.get(card_data["name"])
	else:
		var conca_name = ""
		for n in names:
			if n.match ("ENCHANTED_*"): conca_name += Global.card_name.get(n.substr(10), "")
			elif global.card_name.has(n): conca_name += global.card_name.get(n)
			if splited.count(n) >= 2: conca_name += "(" + str(splited.count(n)) + ")"
		$CardName.text = conca_name

	if $CardName.visible:
		if card_data["type"] == "spell":
			$atk.visible = false
			$hp.visible = false
		if card_data["type"] == "mob":
			$atk.visible = true
			$hp.visible = true
	for ic in $Constant.get_children():
		ic.visible = false
		if has_constant and ic.name in card_data["constant"]: ic.visible = true

	if global.shiny_pool.filter(func(data): return card_data["name"].match ("*" + data + "*")):
		material.set_shader_parameter("shiny", true)
		card_icon.material.set_shader_parameter("shiny", true)
		% Enchanted.emitting = true

	else:
		material.set_shader_parameter("shiny", false)
		card_icon.material.set_shader_parameter("shiny", false)

		if splited.size() > 1: % Enchanted.emitting = true
		else: % Enchanted.emitting = false

	update_font()
func update_font():
	var font_scale = lang_font_scale.get(Global.settings["language"])
	if $CardName.text.length() > font_scale[0]:
		$CardName.add_theme_font_size_override("font_size", max(25 - font_scale[1] * $CardName.text.length(), font_scale[2]))
	else: $CardName.add_theme_font_size_override("font_size", 25)


func _on_mouse_entered():
	if is_dying: return
	z_index += 1
	enlarge()
func enlarge():
	if enlarge_tween != null: enlarge_tween.kill()
	enlarge_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	enlarge_tween.tween_property(self, "scale", Vector2(1.2 * initial_scale.x, 1.2 * initial_scale.y), 0.2)

func _on_mouse_exited():

	if is_dying: return
	z_index -= 1
	shrink()
func shrink():
	if is_dying: return
	if enlarge_tween != null: enlarge_tween.kill()
	enlarge_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	enlarge_tween.tween_property(self, "scale", Vector2(initial_scale.x, initial_scale.y), 0.2)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and movable: left_click(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed() and !dragging: open_card_detail(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed(): clicked.emit(self)

func open_card_detail(_event: InputEventMouseButton):
	global.card_detail_view.show_detail(self)

func left_click(event: InputEventMouseButton):
	if move != null: move.kill()
	if event.is_pressed():
		hitbox = hitbox_scene.instantiate()
		add_child(hitbox)
		top_level = true

		change_stack(1)
		mouse_0 = get_local_mouse_position().rotated(rotation) * scale
		dragging = true
		change_rotation(0)

	elif !event.is_pressed():
		if hitbox != null: hitbox.queue_free()
		top_level = false
		dragging = false
		arc_tween.custom_step(999.0)
		for g in get_tree().get_nodes_in_group("grids"): g.suck(self)

		if data_last_frame == card_data and movable:
			var tmp_arr = get_tree().get_nodes_in_group("in_hand")
			tmp_arr.erase(self)
			for h in tmp_arr:
				h.dragging = false
				h.shrink()

		get_parent().back_to_hand(self)


func grab_all():
	var similar = get_tree().get_nodes_in_group("in_hand").filter(func(c): return Global.same_eff(self.card_data, c.card_data))
	similar.erase(self)
	for s in similar:
		if s.move != null: s.move.kill()
		s.enlarge()
		s.mouse_0 = get_local_mouse_position().rotated(rotation) * scale
		s.dragging = true

func follow_mouse(_delta: float):
	if !dragging: return
	global_position = get_global_mouse_position() - mouse_0

func move_to(end_point: Vector2):
	if dragging or global_position == end_point: return
	if move != null: move.kill()
	move = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	move.tween_property(self, "position", end_point, 0.5)

func play_burn(end_with_visible = false, ease = Tween.EASE_OUT, trans = Tween.TRANS_QUAD, time = 1.2, destroy = true):
	burn_tween_kill()
	if destroy:
		if mouse_filter == MOUSE_FILTER_IGNORE:
			% Enchanted.emitting = false
			$Particles.emitting = false
		if time != 0 and material.get_shader_parameter("dissolve_value") > 0.9:
			$BurnParticleUP.restart()
			$BurnParticleDOWN.restart()
			$BurnParticleLEFT.restart()
			$BurnParticleRIGHT.restart()
			Music.sound_random_fire()
			reset_burn_texture()
		play_unfreeze()
	enchant_tween = create_tween().set_ease(ease).set_trans(trans)
	burn_tween1 = create_tween().set_ease(ease).set_trans(trans)
	burn_tween2 = create_tween().set_ease(ease).set_trans(trans)
	orange_tween = create_tween().set_ease(ease).set_trans(trans)
	var delay = 0.1
	orange_tween.tween_interval(time * delay)

	if destroy:
		enchant_tween.tween_property( % Enchant, "modulate", Color.TRANSPARENT, time)
		orange_tween.tween_property(card_icon.material, "shader_parameter/enable_burn", true, 0.0)
		orange_tween.tween_interval(time * 0.25)
		orange_tween.tween_property(material, "shader_parameter/enable_burn", true, 0.0)
		orange_tween.tween_interval(time * (0.75 - 2 * delay))
		orange_tween.tween_property(card_icon.material, "shader_parameter/enable_burn", false, 0.0)
		orange_tween.tween_interval(time * 0.25)
		orange_tween.tween_property(material, "shader_parameter/enable_burn", false, 0.0)
		burn_tween1.tween_property(card_icon.material, "shader_parameter/dissolve_value", 0.0, time)
		burn_tween2.tween_interval(time / 4)
		burn_tween2.tween_property(material, "shader_parameter/dissolve_value", 0.0, time)
	else:
		enchant_tween.tween_property( % Enchant, "modulate", Color(0.3, 0.3, 0.3, 0.6), time)
		orange_tween.tween_property(material, "shader_parameter/enable_burn", true, 0.0)
		orange_tween.tween_interval(time * 0.25)
		orange_tween.tween_property(card_icon.material, "shader_parameter/enable_burn", true, 0.0)
		orange_tween.tween_interval(time * (0.75 - 2 * delay))
		orange_tween.tween_property(material, "shader_parameter/enable_burn", false, 0.0)
		orange_tween.tween_interval(time * 0.25)
		orange_tween.tween_property(card_icon.material, "shader_parameter/enable_burn", false, 0.0)
		burn_tween1.tween_property(material, "shader_parameter/dissolve_value", 1.0, time)
		burn_tween2.tween_interval(time / 4)
		burn_tween2.tween_property(card_icon.material, "shader_parameter/dissolve_value", 1.0, time)

	await burn_tween2.finished
	if self != null: visible = end_with_visible

func burn_tween_kill():
	if burn_tween1 != null: burn_tween1.kill()
	if burn_tween2 != null: burn_tween2.kill()
	if orange_tween != null: orange_tween.kill()
	if enchant_tween != null: enchant_tween.kill()
func reset_burn_texture():
	material.get_shader_parameter("dissolve_texture").noise.seed = randi()
	card_icon.material.get_shader_parameter("dissolve_texture").noise.seed = randi()

func play_freeze():
	Music.sound_random_snow()

	if freeze_tween != null: freeze_tween.kill()
	freeze_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	freeze_tween.tween_property($Frost.material, "shader_parameter/freeze_progress", 1.0, 0.2)
	freeze_tween.parallel().tween_property(card_icon.material, "shader_parameter/freeze_progress", 1.0, 0.6)
	await get_tree().create_timer(0.12).timeout

func play_unfreeze():

	if freeze_tween != null: freeze_tween.kill()
	freeze_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	freeze_tween.tween_property($Frost.material, "shader_parameter/freeze_progress", 0.0, 0.2)
	freeze_tween.parallel().tween_property(card_icon.material, "shader_parameter/freeze_progress", 0.0, 0.2)
	await get_tree().create_timer(0.12).timeout

func play_do_effect():
	if get_tree() == null: return
	if shake_tween != null and shake_tween.is_running():
		shake_tween.custom_step(999.0)
	shake_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	if arc_tween != null and arc_tween.is_running(): arc_tween.custom_step(999.0)

	shake_tween.tween_property(self, "rotation_degrees", -4, 0.05).as_relative()

	shake_tween.tween_property(self, "rotation_degrees", 4, 0.2).as_relative()
	await get_tree().create_timer(0.2).timeout

func change_rotation(arc, time = 2.0 * abs(rotation - arc)):
	if arc_tween != null and arc_tween.is_running(): arc_tween.custom_step(999.0)
	arc_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	arc_tween.tween_property(self, "rotation", arc, time)

func back_to_pool():
	dragging = false
	disconnect_all_listeners()
	stop_all_emitting()
	if Global.all_resolved.is_connected(back_to_pool): Global.all_resolved.disconnect(back_to_pool)
	for tween in [move, aura_tween, burn_tween1, burn_tween2, orange_tween, enchant_tween, freeze_tween, 
				shake_tween, arc_tween, enlarge_tween, stack_tween, atk_tween, hp_tween, cost_tween]:
		if tween != null and tween.is_running(): tween.custom_step(999.0)

	visible = false
	await get_tree().create_timer(2.0).timeout
	if get_parent() != null: get_parent().remove_child(self)
	Global.card_pool.append(self)

func stop_all_emitting(): for particle in [$Particles, % Enchanted, $BurnParticleUP, $BurnParticleDOWN, $BurnParticleLEFT, $BurnParticleRIGHT]: particle.emitting = false

func recover():
	disconnect_all_listeners()
	stop_all_emitting()
	card_data = {"name": "?", "type": "mob", "atk": 0, "hp": 0, "cost": 0, "id": -1, "spell_boost": 0}
	visible = true
	movable = true
	is_dying = false
	is_casted = false
	dragging = false
	mouse_filter = MOUSE_FILTER_STOP
	initial_scale = Vector2(1.0, 1.0)
	scale = Vector2(1.0, 1.0)
	modulate = Color.WHITE
	change_stack(1)
	rotation = 0
	z_index = 0
	$Frost.material.set_shader_parameter("freeze_progress", 0.0)
	$CardIcon.material.set_shader_parameter("freeze_progress", 0.0)
	$aura.material.set_shader_parameter("alpha", 0.0)
	$CardIcon.material.set_shader_parameter("dissolve_value", 1.0)
	material.set_shader_parameter("dissolve_value", 1.0)

func disconnect_all_listeners(target = self):
	for signal_name in [eat, spell_used, clicked, enter_field]:
		var connections = target.get_signal_connection_list(str(signal_name))
		for conn in connections:
			conn.signal .disconnect(conn.callable)
