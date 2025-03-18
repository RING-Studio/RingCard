class_name CardData extends Resource

enum Type { POLICY, MEASURE, EVENT }
enum TargetType { SELF, OPPONENT, SITE }

@export_group("Visual")
@export var card_name: String
@export_multiline var discription: String
@export var type: Type
@export var cost: int
@export var duration: int = 0 # 政策卡持续回合

@export_subgroup("Texture")
@export var template: Texture # 卡牌模板
@export var illust: Texture # 卡牌插画
@export var back: Texture # 卡背

@export_group("Info")
@export var target_type: TargetType
@export var target_num: int = 0
#@export var sound: AudioStream


func _ready():
	resource_local_to_scene = true


func apply_effects(targets: Array[Node]):
	print_debug(card_name, " played")
	pass
