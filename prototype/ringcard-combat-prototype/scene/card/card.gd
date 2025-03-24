extends Control
class_name Card

@export var card_data: CardData

@onready var drop_area_detector: Area2D = $DropAreaDetector
@onready var card_state_machine: CardStateMachine = $CardStateMachine

@onready var card_visual: Control = $CardVisual
@onready var template_sprite: Sprite2D = $CardVisual/TemplateSprite
@onready var illust_sprite: Sprite2D = $CardVisual/IllustSprite
@onready var back_sprite: Sprite2D = $CardVisual/BackSprite
@onready var name_label: Label = $CardVisual/NameLabel
@onready var discription_label: Label = $CardVisual/DiscriptionLabel
@onready var cost_sprite: Sprite2D = $CardVisual/CostSprite
@onready var cost_label: Label = $CardVisual/CostLabel

signal reparent_requested(card: Card)

# card data
var target_type: CardData.TargetType
var target_num: int
var targets: Array[Node] = []
var random_target: bool = false
var fixed_target_names: Array[String] = [] # 事先固定的目标，有这个就不需要select

var template: Texture # 卡牌模板
var illust: Texture # 卡牌插画
var back: Texture # 卡背

var card_name: String
var discription: String
var type: CardData.Type
var cost: int
var duration: int = 0 # 政策卡持续回合

# tween
var scale_tween: Tween

# debug
var original_global_position


func _ready() -> void:
	for state in card_state_machine.states.values():
		state.card = self
		
	target_type = card_data.target_type
	target_num = card_data.target_num
	random_target = card_data.random_target
	fixed_target_names = card_data.fixed_target_names
	
	template_sprite.texture = card_data.template_texture
	illust_sprite.texture = card_data.illust_texture
	back_sprite.texture = card_data.back_texture
	cost_sprite.texture = card_data.cost_texture
	
	card_name = card_data.card_name
	discription = card_data.discription
	type = card_data.type
	cost = card_data.cost
	duration = card_data.duration
	
	update_card_visual()
	
	# debug
	original_global_position = global_position
	

func update_card_visual():
	name_label.text = card_name
	discription_label.text = discription
	cost_label.text = str(cost)


func _on_mouse_entered():
	z_index += 1
	enlarge()

func _on_mouse_exited():
	z_index -= 1
	shrink()

func enlarge():
	if scale_tween: 
		scale_tween.kill()
	change_scale(Vector2(1.2, 1.2))

func shrink():
	if scale_tween: 
		scale_tween.kill()
	change_scale(Vector2(1.0, 1.0))

func change_scale(
		end_scale: Vector2,
		_last_time: float = 0.2,
		_ease: Tween.EaseType = Tween.EASE_OUT,
		_trans: Tween.TransitionType = Tween.TRANS_QUART
	):
	if scale_tween: 
		scale_tween.kill()
	scale_tween = create_tween().set_ease(_ease).set_trans(_trans)
	scale_tween.tween_property(card_visual, "scale", end_scale, _last_time)


func get_targets(target_type: CardData.TargetType = target_type):
	if fixed_target_names.size() > 0:
		if targets.size() > 0: # 已经获取过
			pass
		else:
			targets = get_sites_by_name(fixed_target_names)
		return
	match target_type:
		CardData.TargetType.SELF:
			targets = get_tree().get_nodes_in_group("player")
		CardData.TargetType.OPPONENT:
			targets = get_tree().get_nodes_in_group("opponent")
		CardData.TargetType.SITE:
			select_targets()
		CardData.TargetType.NONE:
			targets = []
		_:
			print_debug("target_type of card ", card_name, " : ", target_type, " error")


func get_sites_by_name(target_names: Array[String]) -> Array[Node]:
	var targets = []
	var sites = get_tree().get_nodes_in_group("site") as Array[Site]
	for site in sites:
		if site.site_data.site_name in target_names:
			targets.append(site)
	return targets
	

func select_targets(target_num: int = target_num, random_select: bool = false):
	#get_tree().call_group("site", "outline_on")
	
	targets = []
	if random_select:
		var sites = get_tree().get_nodes_in_group("site") as Array[Site]
		var site_count = sites.size()
		if site_count < target_num:
			print_debug("site_count < target_num ", card_data.card_name)
			target_num = site_count
		# 生成索引數組，shuffle並抽取
		if site_count > 0:
			var indices = range(site_count)
			indices.shuffle()
			for i in range(site_count):
				targets.append(sites[indices[i]])
	else:
		Events.start_site_selecting.emit(self)
		await Events.end_site_selecting


func can_drop() -> bool: # 返回卡牌是否在drop区域
	var overlapping_areas = drop_area_detector.get_overlapping_areas()
	if overlapping_areas.size():
		return true
	return false
	
func can_play() -> bool: # TODO:有费用才能打出
	# 为简化，当前没有卡牌在选site才能打出（事实上应该是加入一个序列打出）
	if Utils.get_site_select_current_card():
		return false
	return true

func play() -> bool: # 返回是否成功打出卡牌
	print_debug("targets: ", targets)
	
	Events.card_played.emit(self)
	#char_stats.mana -= cost
	
	card_data.apply_effects(targets)
	
	await card_data.card_play_animation()
	call_deferred("queue_free")

	return true


func put_center():
	# TODO: reparent (or discard Hand)
	var battle = get_tree().get_first_node_in_group("battle") as Battle
	var card_drop_area_center = battle.card_drop_area_color_rect.get_rect().get_center()
	
	var tween = create_tween()
	tween.tween_property(self, "global_position",\
		card_drop_area_center - size / 2.0, 0.1).set_trans(Tween.TRANS_CUBIC)
	
	await tween.finished
	print_debug(global_position)
	pass


func put_back():
	# TODO: reparent (or discard Hand)
	var tween = create_tween()
	tween.tween_property(self, "global_position",\
		original_global_position, 0.1).set_trans(Tween.TRANS_CUBIC)
		
	await tween.finished
	print_debug(global_position)
	pass
