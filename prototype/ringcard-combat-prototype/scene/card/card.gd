extends Control
class_name Card

@export var card_data: CardData

@onready var drop_area_detector: Area2D = $DropAreaDetector
@onready var card_state_machine: CardStateMachine = $CardStateMachine

@onready var template_sprite: Sprite2D = $CardVisual/TemplateSprite
@onready var illust_sprite: Sprite2D = $CardVisual/IllustSprite
@onready var back_sprite: Sprite2D = $CardVisual/BackSprite
@onready var discription_label: Label = $CardVisual/DiscriptionLabel
@onready var cost_label: Label = $CardVisual/CostLabel



signal reparent_requested(card: Card)

var target_type: CardData.TargetType
var target_num: int
var targets: Array[Node] = []

var template: Texture # 卡牌模板
var illust: Texture # 卡牌插画
var back: Texture # 卡背

var card_name: String
var discription: String
var type: CardData.Type
var cost: int
var duration: int = 0 # 政策卡持续回合

# debug
var original_global_position


func _ready() -> void:
	for state in card_state_machine.states.values():
		state.card = self
		
	target_type = card_data.target_type
	target_num = card_data.target_num
	
	template = card_data.template
	illust = card_data.illust
	back = card_data.back
	
	card_name = card_data.card_name
	discription = card_data.discription
	type = card_data.type
	cost = card_data.cost
	duration = card_data.duration
	
	update_card_visual()
	
	# debug
	original_global_position = global_position
	

func update_card_visual():
	template_sprite.texture = template
	illust_sprite.texture = illust
	back_sprite.texture = back
	discription_label.text = discription
	cost_label.text = str(cost)


func get_targets():
	match target_type:
		CardData.TargetType.SELF:
			return get_tree().get_nodes_in_group("player")
		CardData.TargetType.OPPONENT:
			return get_tree().get_nodes_in_group("opponent")
		CardData.TargetType.SITE:
			return get_tree().get_nodes_in_group("site")
		_:
			return []


func choose_targets(target_type: CardData.TargetType):
	targets = get_tree().get_nodes_in_group("player")
	pass


func can_drop() -> bool: # 返回卡牌是否在drop区域
	var overlapping_areas = drop_area_detector.get_overlapping_areas()
	if overlapping_areas.size():
		return true
	return false


func play() -> bool: # 返回是否成功打出卡牌
	choose_targets(target_type)
	put_center()
	
	card_data.apply_effects(targets)
	
	Events.card_played.emit(self)
	#char_stats.mana -= cost

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
