extends Control
class_name Card

@export var card_data: CardData

@onready var drop_area_detector: Area2D = $DropAreaDetector
@onready var card_state_machine: CardStateMachine = $CardStateMachine

signal reparent_requested(card: Card)

var target_type: CardData.TargetType
var target_num: int
var targets: Array[Node] = []

# debug
var original_global_position


func _ready() -> void:
	for state in card_state_machine.states.values():
		state.card = self
		
	target_type = card_data.target_type
	target_num = card_data.target_num
	
	# debug
	original_global_position = global_position

func get_targets():
	match target_type:
		CardData.TargetType.SELF:
			return get_tree().get_nodes_in_group("player")
		CardData.TargetType.OPPONENT:
			return get_tree().get_nodes_in_group("opponent")
		CardData.TargetType.AREA:
			return get_tree().get_nodes_in_group("area")
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
